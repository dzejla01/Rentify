using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using Rentify.WebAPI.Configuration;
using Stripe;
using System.IO;
using System.Security.Claims;

namespace Rentify.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaymentController : BaseCRUDController<PaymentResponse, PaymentSearchObject, PaymentUpsertRequest, PaymentUpsertRequest>
    {
        private readonly StripeSettings _stripeSettings;

        public PaymentController(
            IPaymentService paymentService,
            StripeSettings stripeSettings
        ) : base(paymentService)
        {
            _stripeSettings = stripeSettings;
        }

        [Authorize(Roles = "Admin,Vlasnik,Korisnik")]
        public override async Task<PagedResult<PaymentResponse>> Get([FromQuery] PaymentSearchObject? search = null)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdClaim, out var loggedInId))
                throw new UnauthorizedAccessException("Neispravan token.");

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin)
            {
                search ??= new PaymentSearchObject();

                if (User.IsInRole("Vlasnik"))
                    search.OwnerId = loggedInId;
                else
                    search.UserId = loggedInId;
            }

            return await base.Get(search);
        }

        [Authorize(Roles = "Admin,Vlasnik,Korisnik")]
        public override async Task<PaymentResponse?> GetById(int id)
        {
            var result = await base.GetById(id);
            if (result == null) return null;

            if (User.IsInRole("Admin"))
                return result;

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdClaim, out var loggedInId))
                throw new UnauthorizedAccessException("Neispravan token.");

            if (User.IsInRole("Vlasnik"))
            {
                if (result.Reservation?.Property?.UserId != loggedInId)
                    throw new UnauthorizedAccessException("Nemate pristup ovoj uplati.");

                return result;
            }

            if (result.Reservation?.UserId != loggedInId)
                throw new UnauthorizedAccessException("Nemate pristup ovoj uplati.");

            return result;
        }

        [Authorize(Roles = "Admin,Vlasnik")]
        public override Task<PaymentResponse> Create([FromBody] PaymentUpsertRequest request)
        {
            return base.Create(request);
        }

        [Authorize(Roles = "Admin")]
        public override Task<PaymentResponse?> Update(int id, [FromBody] PaymentUpsertRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override Task<bool> Delete(int id)
        {
            return base.Delete(id);
        }

        [Authorize(Roles = "Korisnik,Admin")]
        [HttpPost("create-new-intent")]
        public async Task<IActionResult> CreateNewPaymentIntent([FromBody] CreatePaymentIntentRequest req)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (!int.TryParse(userIdClaim, out var loggedInUserId))
                    return Unauthorized("Neispravan token.");

                var isAdmin = User.IsInRole("Admin");
                if (!isAdmin)
                    req.UserId = loggedInUserId;

                var result = await (_service as IPaymentService).CreateNewPaymentIntentAsync(req);
                return Ok(result);
            }
            catch (UserException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (StripeException)
            {
                return StatusCode(500, "Greška sa Stripe servisom.");
            }
            catch (Exception)
            {
                return StatusCode(500, "Greška prilikom kreiranja payment intenta.");
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

                var signatureHeader = Request.Headers["Stripe-Signature"];

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
                    await (_service as IPaymentService).HandlePaymentIntentSucceededAsync(
                        paymentIntent.Id,
                        paymentIntent.Metadata
                    );
                }
                else if (stripeEvent.Type == "payment_intent.payment_failed")
                {
                    await (_service as IPaymentService).HandlePaymentIntentFailedAsync(
                        paymentIntent.Id,
                        paymentIntent.Metadata
                    );
                }
                else if (stripeEvent.Type == "payment_intent.canceled")
                {
                    await (_service as IPaymentService).HandlePaymentIntentCanceledAsync(
                        paymentIntent.Id,
                        paymentIntent.Metadata
                    );
                }

                return Ok();
            }
            catch (StripeException)
            {
                return BadRequest("Neispravan webhook.");
            }
            catch (Exception)
            {
                return StatusCode(500, "Greška pri webhook obradi.");
            }
        }
    }
}