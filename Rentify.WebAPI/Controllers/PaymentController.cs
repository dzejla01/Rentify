using System.IO;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;
using Rentify.WebAPI.Configuration;
using Stripe;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentController
        : BaseCRUDController<PaymentResponse, PaymentSearchObject, PaymentUpsertRequest, PaymentUpsertRequest>
    {
        private readonly StripeSettings _stripeSettings;
        private readonly IPaymentService _paymentService;

        public PaymentController(
            IPaymentService service,
            StripeSettings stripeSettings
        ) : base(service)
        {
            _paymentService = service;
            _stripeSettings = stripeSettings;
        }

        //[Authorize(Roles = "Korisnik")]
        [HttpPost("create-new-intent")]
        public async Task<IActionResult> CreateNewPaymentIntent([FromBody] CreatePaymentIntentRequest req)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrWhiteSpace(userIdClaim) || !int.TryParse(userIdClaim, out var loggedInUserId))
                    return Unauthorized("Neispravan token");

                var isAdmin = User.IsInRole("Admin");

                if (!isAdmin && req.UserId != loggedInUserId)
                    return Forbid("Nije dozvoljeno kreirati payment intent za drugog korisnika.");

                var result = await _paymentService.CreateNewPaymentIntentAsync(req);
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (StripeException)
            {
                return StatusCode(500, "Greška prilikom komunikacije sa Stripe servisom.");
            }
            catch (Exception)
            {
                return StatusCode(500, "Došlo je do greške prilikom kreiranja payment intenta.");
            }
        }

        [AllowAnonymous]
        [HttpPost("webhook")]
        public async Task<IActionResult> StripeWebhook()
        {
            try
            {
                using var reader = new StreamReader(HttpContext.Request.Body);
                var json = await reader.ReadToEndAsync();

                var signatureHeader = Request.Headers["Stripe-Signature"].ToString();

                var stripeEvent = EventUtility.ConstructEvent(
                    json,
                    signatureHeader,
                    _stripeSettings.WebhookSecret,  
                    throwOnApiVersionMismatch: false
                );

                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                if (paymentIntent == null)
                    return Ok();

                if (stripeEvent.Type == "payment_intent.succeeded")
                {
                    await _paymentService.HandlePaymentIntentSucceededAsync(
                        paymentIntent.Id,
                        paymentIntent.Metadata
                    );
                }
                else if (stripeEvent.Type == "payment_intent.payment_failed")
                {
                    await _paymentService.HandlePaymentIntentFailedAsync(
                        paymentIntent.Id,
                        paymentIntent.Metadata
                    );
                }
                else if (stripeEvent.Type == "payment_intent.canceled")
                {
                    await _paymentService.HandlePaymentIntentCanceledAsync(
                        paymentIntent.Id,
                        paymentIntent.Metadata
                    );
                }

                return Ok();
            }
            catch (StripeException)
            {
                return BadRequest("Neispravan Stripe webhook potpis ili payload.");
            }
            catch (Exception)
            {
                return StatusCode(500, "Greška pri obradi Stripe webhook-a.");
            }
        }
    }
}