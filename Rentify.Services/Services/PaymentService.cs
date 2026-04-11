using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Rentify.EmailConsumer.Configuration;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using System;
using System.Linq;

namespace Rentify.Services.Services
{
    public class PaymentService
        : BaseCRUDService<PaymentResponse, PaymentSearchObject, Payment, PaymentUpsertRequest, PaymentUpsertRequest>,
          IPaymentService
    {
        private readonly IDeviceTokenService _deviceTokenService;
        private readonly PushNotificationService _pushService;
        private readonly IStripeService _stripeService;
        private readonly AppConfig _config;

        public PaymentService(
            RentifyDbContext context,
            IMapper mapper,
            IDeviceTokenService deviceTokenService,
            PushNotificationService pushService,
            IStripeService stripeService,
            IOptions<AppConfig> config
        ) : base(context, mapper)
        {
            _deviceTokenService = deviceTokenService;
            _pushService = pushService;
            _stripeService = stripeService;
            _config = config.Value;
        }

        protected override IQueryable<Payment> ApplyFilter(IQueryable<Payment> query, PaymentSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.FTS))
            {
                var fts = search.FTS.ToLower();

                query = query.Where(x =>
                    x.Name.ToLower().Contains(fts)
                    ||
                    (x.MonthNumber.ToString().PadLeft(2, '0') + "." + x.YearNumber.ToString()).Contains(fts)
                    ||
                    ("uplaćeno".Contains(fts) && x.IsPayed == true)
                    ||
                    ("na čekanju".Contains(fts) && x.IsPayed == false)
                    ||
                    ((x.PaymentStatus ?? "").ToLower().Contains(fts))
                );
            }

            if (search.ReservationId.HasValue)
                query = query.Where(x => x.ReservationId == search.ReservationId);

            if (search.UserId.HasValue)
                query = query.Where(x => x.Reservation.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.Reservation.PropertyId == search.PropertyId.Value);

            if (search.IsPayed.HasValue)
                query = query.Where(x => x.IsPayed == search.IsPayed.Value);

            if (search.MonthNumber.HasValue)
                query = query.Where(x => x.MonthNumber == search.MonthNumber.Value);

            if (search.YearNumber.HasValue)
                query = query.Where(x => x.YearNumber == search.YearNumber.Value);

            if (!string.IsNullOrEmpty(search.ReservationStatus))
                query = query.Where(x => x.Reservation.Status == search.ReservationStatus);

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Payment> AddInclude(IQueryable<Payment> query, PaymentSearchObject search)
        {
            query = query.Include(r => r.Reservation);

            return base.AddInclude(query, search);
        }

        protected override async Task AfterInsert(Payment entity, PaymentUpsertRequest request)
        {
            if (entity.IsPayed == false)
            {
                var reservationUserId = await _context.Reservations
                    .Where(x => x.Id == entity.ReservationId)
                    .Select(x => x.UserId)
                    .FirstOrDefaultAsync();

                if (reservationUserId == 0)
                    return;

                try
                {
                    var tokens = await _deviceTokenService.GetActiveTokensAsync(reservationUserId);

                    await _pushService.SendToTokensAsync(
                        tokens,
                        "Rentify",
                        "Imate novi zahtjev za plaćanje.",
                        new Dictionary<string, string>
                        {
                            ["type"] = "payment_request",
                            ["paymentId"] = entity.Id.ToString()
                        }
                    );
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Push failed: {ex.Message}");
                }
            }
        }

        public async Task<object> CreateNewPaymentIntentAsync(CreatePaymentIntentRequest req)
        {
            var payment = await _context.Payments
    .Include(x => x.Reservation)
    .FirstOrDefaultAsync(x => x.Id == req.PaymentId);

            if (payment == null)
                throw new NotFoundException("Payment nije pronađen.");

            if (payment.Reservation == null)
                throw new NotFoundException("Reservation nije pronađena za ovaj payment.");

            if (payment.Reservation.UserId != req.UserId)
                throw new ArgumentException("Payment ne pripada korisniku.");

            var metadata = new Dictionary<string, string>
            {
                ["paymentId"] = payment.Id.ToString(),
                ["userId"] = payment.Reservation.UserId.ToString(),
                ["propertyId"] = payment.Reservation.PropertyId.ToString()
            };

            var intent = await _stripeService.CreatePaymentIntentAsync(
                payment.Price,
                _config.PaymentCurrency,
                metadata
            );

            payment.StripePaymentIntentId = intent.Id;
            payment.PaymentStatus = "Processing";

            await _context.SaveChangesAsync();

            return new
            {
                clientSecret = intent.ClientSecret,
                intentId = intent.Id,
                paymentId = payment.Id,
                amount = payment.Price
            };
        }

        public async Task HandlePaymentIntentSucceededAsync(string paymentIntentId, IDictionary<string, string> metadata)
        {
            if (!metadata.TryGetValue("paymentId", out var paymentIdString))
                return;

            if (!int.TryParse(paymentIdString, out var paymentId))
                return;

            var payment = await _context.Payments.FirstOrDefaultAsync(x => x.Id == paymentId);
            if (payment == null || payment.PaymentStatus == "Paid")
                return;

            payment.IsPayed = true;
            payment.PaymentStatus = "Paid";
            payment.PaidAt = DateTime.UtcNow;
            payment.StripePaymentIntentId = paymentIntentId;

            await _context.SaveChangesAsync();
        }

        public async Task HandlePaymentIntentFailedAsync(string paymentIntentId, IDictionary<string, string> metadata)
        {
            if (!metadata.TryGetValue("paymentId", out var paymentIdString))
                return;

            if (!int.TryParse(paymentIdString, out var paymentId))
                return;

            var payment = await _context.Payments.FirstOrDefaultAsync(x => x.Id == paymentId);
            if (payment == null || payment.PaymentStatus == "Paid")
                return;

            payment.PaymentStatus = "Failed";
            payment.StripePaymentIntentId = paymentIntentId;

            await _context.SaveChangesAsync();
        }

        public async Task HandlePaymentIntentCanceledAsync(string paymentIntentId, IDictionary<string, string> metadata)
        {
            if (!metadata.TryGetValue("paymentId", out var paymentIdString))
                return;

            if (!int.TryParse(paymentIdString, out var paymentId))
                return;

            var payment = await _context.Payments.FirstOrDefaultAsync(x => x.Id == paymentId);
            if (payment == null || payment.PaymentStatus == "Paid")
                return;

            payment.PaymentStatus = "Canceled";
            payment.StripePaymentIntentId = paymentIntentId;

            await _context.SaveChangesAsync();
        }
    }
}