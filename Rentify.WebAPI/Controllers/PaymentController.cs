using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using Rentify.WebAPI.Configuration;
using Rentify.WebAPI.Services;
using Stripe;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentController
        : BaseCRUDController<PaymentResponse, PaymentSearchObject, PaymentUpsertRequest, PaymentUpsertRequest>
    {
        private readonly RentifyDbContext _context;
        private readonly StripeService _stripeService;
        private readonly StripeSettings _stripeSettings;

        public PaymentController(
            IPaymentService service,
            RentifyDbContext context,
            StripeService stripeService,
            IOptions<StripeSettings> stripeOptions
        ) : base(service)
        {
            _context = context;
            _stripeService = stripeService;
            _stripeSettings = stripeOptions.Value;
        }

        // POST: api/payments/{id}/create-intent
        [HttpPost("{id:int}/create-intent")]
        public async Task<IActionResult> CreatePaymentIntent(int id)
        {
            var payment = await _context.Payments.FirstOrDefaultAsync(x => x.Id == id);
            if (payment == null)
                return NotFound("Payment nije pronađen.");

            if (payment.IsPayed == true)
                return BadRequest("Uplata je već plaćena.");

            // Metadata - koristi se na webhooku da znamo koji je payment u bazi
            var metadata = new Dictionary<string, string>
            {
                ["paymentId"] = payment.Id.ToString(),
                ["userId"] = payment.UserId.ToString(),
                ["propertyId"] = payment.PropertyId.ToString()
            };

            // Kreiraj PaymentIntent u Stripe
            var intent = await _stripeService.CreatePaymentIntentAsync(
                amount: payment.Price,
                currency: "eur", // preporuka za test; BAM često nije podržan
                metadata: metadata
            );

            // Snimi intent id + status u bazi
            payment.StripePaymentIntentId = intent.Id;
            payment.PaymentStatus = "Processing";

            await _context.SaveChangesAsync();

            // Flutter koristi clientSecret u PaymentSheet-u
            return Ok(new
            {
                clientSecret = intent.ClientSecret
            });
        }

        // POST: api/payments/webhook
        [AllowAnonymous]
        [HttpPost("webhook")]
        public async Task<IActionResult> StripeWebhook()
        {
            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();

            try
            {
                var signatureHeader = Request.Headers["Stripe-Signature"].ToString();

                // Validacija webhook signature-a
                var stripeEvent = EventUtility.ConstructEvent(
                    json,
                    signatureHeader,
                    _stripeSettings.WebhookSecret
                );

                // ✅ Uspješno plaćanje
                if (stripeEvent.Type == "payment_intent.succeeded")
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;

                    if (paymentIntent?.Metadata == null)
                        return Ok();

                    if (!paymentIntent.Metadata.TryGetValue("paymentId", out var paymentIdString))
                        return Ok();

                    if (!int.TryParse(paymentIdString, out var paymentId))
                        return Ok();

                    var payment = await _context.Payments.FirstOrDefaultAsync(x => x.Id == paymentId);
                    if (payment == null)
                        return Ok();

                    // Idempotentno (Stripe može poslati isti event više puta)
                    if (payment.IsPayed == true)
                        return Ok();

                    payment.IsPayed = true;
                    payment.PaymentStatus = "Paid";
                    payment.PaidAt = DateTime.UtcNow;
                    payment.StripePaymentIntentId = paymentIntent.Id;

                    await _context.SaveChangesAsync();
                }
                else if (stripeEvent.Type == "payment_intent.payment_failed")
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;

                    if (paymentIntent?.Metadata == null)
                        return Ok();

                    if (paymentIntent.Metadata.TryGetValue("paymentId", out var paymentIdString) &&
                        int.TryParse(paymentIdString, out var paymentId))
                    {
                        var payment = await _context.Payments.FirstOrDefaultAsync(x => x.Id == paymentId);
                        if (payment != null && payment.IsPayed != true)
                        {
                            payment.PaymentStatus = "Failed";
                            payment.StripePaymentIntentId = paymentIntent.Id;
                            await _context.SaveChangesAsync();
                        }
                    }
                }

                return Ok();
            }
            catch (StripeException e)
            {
                return BadRequest($"Stripe error: {e.Message}");
            }
            catch (Exception e)
            {
                return BadRequest($"Webhook error: {e.Message}");
            }
        }
    }
}