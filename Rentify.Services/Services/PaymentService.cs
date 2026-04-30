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
using Rentify.Services.PaymentStateMachine;

namespace Rentify.Services.Services
{
    public class PaymentService : BaseCRUDService<PaymentResponse, PaymentSearchObject, Payment, PaymentUpsertRequest, PaymentUpsertRequest>, IPaymentService
    {
        private readonly IStripeService _stripeService;
        private readonly IDeviceTokenService _deviceTokenService;
        private readonly PushNotificationService _pushService;
        private readonly AppConfig _config;
        private readonly BasePaymentState _paymentStateService;

        public PaymentService(
            RentifyDbContext context,
            IStripeService stripeService,
            IDeviceTokenService deviceToken,
            PushNotificationService push,
            IMapper mapper,
            IOptions<AppConfig> config,
            BasePaymentState paymentStateService
        ) : base(context, mapper)
        {
            _deviceTokenService = deviceToken;
            _pushService = push;
            _stripeService = stripeService;
            _config = config.Value;
            _paymentStateService = paymentStateService;
        }

        public override async Task<PagedResult<PaymentResponse>> GetAsync(PaymentSearchObject search)
        {
            await ResolveExpiredPaymentDeadlinesAsync();
            return await base.GetAsync(search);
        }

        public override async Task<PaymentResponse?> GetByIdAsync(int id)
        {
            await ResolveExpiredPaymentDeadlinesAsync(id);
            return await base.GetByIdAsync(id);
        }

        private async Task ResolveExpiredPaymentDeadlinesAsync(int? paymentId = null)
        {
            var now = DateTime.UtcNow;

            var query = _context.Payments
                .Include(p => p.Reservation)
                .Where(p => p.SecondWarningDate != null)
                .Where(p => p.SecondWarningDate!.Value <= now)
                .Where(p =>
                    p.PaymentStatus == "Na čekanju" ||
                    p.PaymentStatus == "Procesiranje");

            if (paymentId.HasValue)
                query = query.Where(p => p.Id == paymentId.Value);

            var expiredPayments = await query.ToListAsync();

            if (!expiredPayments.Any())
                return;

            foreach (var payment in expiredPayments)
            {
                payment.PaymentStatus = "Neplaćeno";
                payment.PaidAt = null;

                if (payment.Reservation != null &&
                    payment.Reservation.Status != "Otkazano" &&
                    payment.Reservation.Status != "Završeno" &&
                    payment.Reservation.Status != "Odbijeno")
                {
                    payment.Reservation.Status = "Otkazano";
                }
            }

            await _context.SaveChangesAsync();
        }

        protected override IQueryable<Payment> ApplyFilter(IQueryable<Payment> query, PaymentSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = string.Join(" ", search.FTS.Trim().ToLower().Split(' ', StringSplitOptions.RemoveEmptyEntries));

                query = query.Where(x =>
                    x.Name.ToLower().Contains(fts)
                    || (x.Comment != null && x.Comment.ToLower().Contains(fts))
                    || (x.Reservation != null && x.Reservation.Property != null && x.Reservation.Property.Name.ToLower().Contains(fts))
                    || (x.Reservation != null && x.Reservation.User != null && x.Reservation.User.FirstName.ToLower().Contains(fts))
                    || (x.Reservation != null && x.Reservation.User != null && x.Reservation.User.LastName.ToLower().Contains(fts))
                    || (x.Reservation != null && x.Reservation.User != null && (x.Reservation.User.FirstName + " " + x.Reservation.User.LastName).ToLower().Contains(fts))
                    || (x.Reservation != null && x.Reservation.User != null && (x.Reservation.User.LastName + " " + x.Reservation.User.FirstName).ToLower().Contains(fts))
                    || (x.MonthNumber.ToString().PadLeft(2, '0') + "." + x.YearNumber.ToString()).Contains(fts)
                    || ((x.PaymentStatus ?? "").ToLower().Contains(fts))
                    || (fts.Contains("plaćeno") && x.PaymentStatus == "Plaćeno")
                    || (fts.Contains("placeno") && x.PaymentStatus == "Plaćeno")
                    || (fts.Contains("na čekanju") && x.PaymentStatus == "Na čekanju")
                    || (fts.Contains("na cekanju") && x.PaymentStatus == "Na čekanju")
                    || (fts.Contains("procesiranje") && x.PaymentStatus == "Procesiranje")
                    || (fts.Contains("neplaćeno") && x.PaymentStatus == "Neplaćeno")
                    || (fts.Contains("neplaceno") && x.PaymentStatus == "Neplaćeno")
                    || (fts.Contains("otkazano") && x.PaymentStatus == "Otkazano")
                    || (fts.Contains("neuspješno") && x.PaymentStatus == "Neuspješno")
                    || (fts.Contains("neuspjesno") && x.PaymentStatus == "Neuspješno")
                );
            }

            if (search.ReservationId.HasValue)
                query = query.Where(x => x.ReservationId == search.ReservationId.Value);

            if (search.UserId.HasValue)
                query = query.Where(x => x.Reservation != null && x.Reservation.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.Reservation != null && x.Reservation.PropertyId == search.PropertyId.Value);

            if (!string.IsNullOrWhiteSpace(search.PaymentStatus))
                query = query.Where(x => x.PaymentStatus == search.PaymentStatus);

            if (search.MonthNumber.HasValue)
                query = query.Where(x => x.MonthNumber == search.MonthNumber.Value);

            if (search.YearNumber.HasValue)
                query = query.Where(x => x.YearNumber == search.YearNumber.Value);

            if (!string.IsNullOrWhiteSpace(search.ReservationStatus))
                query = query.Where(x => x.Reservation != null && x.Reservation.Status == search.ReservationStatus);

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Payment> AddInclude(IQueryable<Payment> query, PaymentSearchObject search)
        {
            query = query.Include(x => x.Reservation);

            if (search.IncludeUser == true)
                query = query.Include(x => x.Reservation!).ThenInclude(x => x.User);

            if (search.IncludeProperty == true)
                query = query.Include(x => x.Reservation!).ThenInclude(x => x.Property);

            return base.AddInclude(query, search);
        }

        protected override async Task BeforeInsert(Payment entity, PaymentUpsertRequest request)
        {
            entity.PaymentStatus = string.IsNullOrWhiteSpace(entity.PaymentStatus)
                ? "Na čekanju"
                : entity.PaymentStatus;

            entity.PaidAt = entity.PaymentStatus == "Plaćeno"
                ? entity.PaidAt ?? DateTime.UtcNow
                : null;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Payment entity, PaymentUpsertRequest request)
        {
            if (entity.PaymentStatus == "Plaćeno" && entity.PaidAt == null)
                entity.PaidAt = DateTime.UtcNow;

            if (entity.PaymentStatus != "Plaćeno")
                entity.PaidAt = null;

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task AfterInsert(Payment entity, PaymentUpsertRequest request)
        {
            if (entity.PaymentStatus != "Na čekanju")
                return;

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

        public async Task<object> CreateNewPaymentIntentAsync(CreatePaymentIntentRequest req)
        {
            var payment = await _context.Payments
                .Include(x => x.Reservation)
                .FirstOrDefaultAsync(x => x.Id == req.PaymentId);

            if (payment == null)
                throw new NotFoundException("Payment nije pronađen.");

            if (payment.Reservation == null)
                throw new NotFoundException("Reservation nije pronađena.");

            if (payment.Reservation.UserId != req.UserId)
                throw new UserException("Payment ne pripada korisniku.");

            if (payment.PaymentStatus == "Plaćeno")
                throw new UserException("Uplata je već plaćena.");

            if (payment.PaymentStatus == "Otkazano")
                throw new UserException("Uplata je otkazana.");

            if (payment.PaymentStatus == "Neplaćeno")
                throw new UserException("Uplata je označena kao neplaćena.");

            if (payment.PaymentStatus == "Neuspješno")
                throw new UserException("Uplata je neuspješna. Kreirajte novi zahtjev za plaćanje.");

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
            await _context.SaveChangesAsync();

            var state = GetPaymentStateForStatus(payment.PaymentStatus);
            await state.ToProcessingAsync(payment.Id);

            return new
            {
                clientSecret = intent.ClientSecret,
                intentId = intent.Id,
                paymentId = payment.Id,
                amount = payment.Price
            };
        }

        public async Task HandlePaymentIntentSucceededAsync(
            string paymentIntentId,
            IDictionary<string, string> metadata
        )
        {
            var payment = await GetPaymentFromMetadataAsync(paymentIntentId, metadata);

            if (payment == null)
                return;

            var state = GetPaymentStateForStatus(payment.PaymentStatus);
            await state.ToPaidAsync(payment.Id);
        }

        public async Task HandlePaymentIntentFailedAsync(
            string paymentIntentId,
            IDictionary<string, string> metadata
        )
        {
            var payment = await GetPaymentFromMetadataAsync(paymentIntentId, metadata);

            if (payment == null)
                return;

            var state = GetPaymentStateForStatus(payment.PaymentStatus);
            await state.ToFailedAsync(payment.Id);
        }

        public async Task HandlePaymentIntentCanceledAsync(
            string paymentIntentId,
            IDictionary<string, string> metadata
        )
        {
            var payment = await GetPaymentFromMetadataAsync(paymentIntentId, metadata);

            if (payment == null)
                return;

            var state = GetPaymentStateForStatus(payment.PaymentStatus);
            await state.ToCancelledAsync(payment.Id);
        }

        private async Task<Payment?> GetPaymentFromMetadataAsync(
            string paymentIntentId,
            IDictionary<string, string> metadata
        )
        {
            if (!metadata.TryGetValue("paymentId", out var paymentIdString))
                return null;

            if (!int.TryParse(paymentIdString, out var paymentId))
                return null;

            var payment = await _context.Payments
                .FirstOrDefaultAsync(x => x.Id == paymentId);

            if (payment == null)
                return null;

            payment.StripePaymentIntentId = paymentIntentId;
            await _context.SaveChangesAsync();

            return payment;
        }

        private BasePaymentState GetPaymentStateForStatus(string? status)
        {
            return status switch
            {
                "Na čekanju" => _paymentStateService.GetState(nameof(PendingPaymentState)),
                "Procesiranje" => _paymentStateService.GetState(nameof(ProcessingPaymentState)),
                "Plaćeno" => _paymentStateService.GetState(nameof(PaidPaymentState)),
                "Neplaćeno" => _paymentStateService.GetState(nameof(UnpaidPaymentState)),
                "Otkazano" => _paymentStateService.GetState(nameof(CancelledPaymentState)),
                "Neuspješno" => _paymentStateService.GetState(nameof(FailedPaymentState)),

                _ => throw new UserException($"Status uplate '{status}' nije podržan.")
            };
        }
    }
}
