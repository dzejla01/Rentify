using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
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
        private readonly ILogger<PaymentService> _logger;
        private readonly INotificationService _notificationService;

        public PaymentService(
            RentifyDbContext context,
            IStripeService stripeService,
            IDeviceTokenService deviceToken,
            PushNotificationService push,
            IMapper mapper,
            IOptions<AppConfig> config,
            BasePaymentState paymentStateService,
            ILogger<PaymentService> logger,
            INotificationService notificationService
        ) : base(context, mapper)
        {
            _deviceTokenService = deviceToken;
            _pushService = push;
            _stripeService = stripeService;
            _config = config.Value;
            _paymentStateService = paymentStateService;
            _logger = logger;
            _notificationService = notificationService;
        }

        public override async Task<PagedResult<PaymentResponse>> GetAsync(PaymentSearchObject search)
        {
            await ResolveExpiredPaymentDeadlinesAsync();
            return await base.GetAsync(search);
        }

        public override async Task<PaymentResponse?> GetByIdAsync(int id)
        {
            await ResolveExpiredPaymentDeadlinesAsync(id);

            var entity = await _context.Payments
                .Include(p => p.Reservation)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (entity == null) return null;
            return MapToResponse(entity);
        }

        private async Task ResolveExpiredPaymentDeadlinesAsync(int? paymentId = null)
        {
            var now = DateTime.UtcNow;

            var query = _context.Payments
                .Include(p => p.Reservation)
                .Where(p => p.SecondWarningDate != null)
                .Where(p => p.SecondWarningDate!.Value <= now)
                .Where(p =>
                    p.StatusId == 1 ||
                    p.StatusId == 6);

            if (paymentId.HasValue)
                query = query.Where(p => p.Id == paymentId.Value);

            var expiredPayments = await query.ToListAsync();

            if (!expiredPayments.Any())
                return;

            foreach (var payment in expiredPayments)
            {
                payment.StatusId = 8;
                payment.PaidAt = null;

                if (payment.Reservation != null &&
                    payment.Reservation.StatusId != 5 &&
                    payment.Reservation.StatusId != 3 &&
                    payment.Reservation.StatusId != 4)
                {
                    payment.Reservation.StatusId = 5;
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
                    || (x.Status != null && x.Status.Name.ToLower().Contains(fts))
                    || (fts.Contains("plaćeno") && x.StatusId == 7)
                    || (fts.Contains("placeno") && x.StatusId == 7)
                    || (fts.Contains("na čekanju") && x.StatusId == 1)
                    || (fts.Contains("na cekanju") && x.StatusId == 1)
                    || (fts.Contains("procesiranje") && x.StatusId == 6)
                    || (fts.Contains("neplaćeno") && x.StatusId == 8)
                    || (fts.Contains("neplaceno") && x.StatusId == 8)
                    || (fts.Contains("otkazano") && x.StatusId == 5)
                    || (fts.Contains("neuspješno") && x.StatusId == 9)
                    || (fts.Contains("neuspjesno") && x.StatusId == 9)
                );
            }

            if (search.ReservationId.HasValue)
                query = query.Where(x => x.ReservationId == search.ReservationId.Value);

            if (search.UserId.HasValue)
                query = query.Where(x => x.Reservation != null && x.Reservation.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.Reservation != null && x.Reservation.PropertyId == search.PropertyId.Value);

            if (search.StatusId.HasValue)
                query = query.Where(x => x.StatusId == search.StatusId.Value);

            if (search.MonthNumber.HasValue)
                query = query.Where(x => x.MonthNumber == search.MonthNumber.Value);

            if (search.YearNumber.HasValue)
                query = query.Where(x => x.YearNumber == search.YearNumber.Value);

            if (search.ReservationStatusId.HasValue)
                query = query.Where(x => x.Reservation != null && x.Reservation.StatusId == search.ReservationStatusId.Value);

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Payment> AddInclude(IQueryable<Payment> query, PaymentSearchObject search)
        {
            query = query
                .Include(x => x.Status)
                .Include(x => x.Reservation!).ThenInclude(r => r.Status);

            if (search.IncludeUser == true)
                query = query.Include(x => x.Reservation!).ThenInclude(x => x.User);

            if (search.IncludeProperty == true)
                query = query.Include(x => x.Reservation!).ThenInclude(x => x.Property)
                             .Include(x => x.Reservation!).ThenInclude(x => x.Property).ThenInclude(p => p.City)
                             .Include(x => x.Reservation!).ThenInclude(x => x.Property).ThenInclude(p => p.BuildingType);

            return base.AddInclude(query, search);
        }

        protected override async Task BeforeInsert(Payment entity, PaymentUpsertRequest request)
        {
            if (entity.StatusId == 0)
                entity.StatusId = 1;

            entity.PaidAt = entity.StatusId == 7
                ? entity.PaidAt ?? DateTime.UtcNow
                : null;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Payment entity, PaymentUpsertRequest request)
        {
            var newStatusId = request.StatusId != 0 ? request.StatusId : entity.StatusId;

            if (newStatusId == 7 && entity.PaidAt == null)
                entity.PaidAt = DateTime.UtcNow;

            if (newStatusId != 7)
                entity.PaidAt = null;

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task AfterInsert(Payment entity, PaymentUpsertRequest request)
        {
            if (entity.StatusId != 1)
                return;

            var reservationUserId = await _context.Reservations
                .Where(x => x.Id == entity.ReservationId)
                .Select(x => x.UserId)
                .FirstOrDefaultAsync();

            if (reservationUserId == 0)
                return;

            await _notificationService.CreateForUserAsync(
                reservationUserId,
                "Novi zahtjev za placanje",
                "Imate novi zahtjev za placanje.",
                type: "payment_request",
                referenceType: "payment",
                referenceId: entity.Id
            );

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
                _logger.LogWarning(ex, "Slanje push notifikacije za novi zahtjev za placanje nije uspjelo.");
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

            if (payment.StatusId == 7)
                throw new UserException("Uplata je već plaćena.");

            if (payment.StatusId == 6 && !string.IsNullOrWhiteSpace(payment.StripePaymentIntentId))
                throw new UserException("Plaćanje je već u toku. Sačekajte završetak tekuće transakcije.");

            if (payment.StatusId == 5)
                throw new UserException("Uplata je otkazana.");

            if (payment.StatusId == 8)
                throw new UserException("Uplata je označena kao neplaćena.");

            if (payment.StatusId == 9)
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

            var state = GetPaymentStateForStatus(payment.StatusId);
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

            if (payment.StatusId == 7)
                return;

            var state = GetPaymentStateForStatus(payment.StatusId);
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

            var state = GetPaymentStateForStatus(payment.StatusId);
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

            var state = GetPaymentStateForStatus(payment.StatusId);
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

            if (string.IsNullOrWhiteSpace(payment.StripePaymentIntentId))
            {
                payment.StripePaymentIntentId = paymentIntentId;
                await _context.SaveChangesAsync();
            }

            return payment;
        }

        private BasePaymentState GetPaymentStateForStatus(int statusId)
        {
            return statusId switch
            {
                1    => _paymentStateService.GetState(nameof(PendingPaymentState)),
                6 => _paymentStateService.GetState(nameof(ProcessingPaymentState)),
                7       => _paymentStateService.GetState(nameof(PaidPaymentState)),
                8     => _paymentStateService.GetState(nameof(UnpaidPaymentState)),
                5  => _paymentStateService.GetState(nameof(CancelledPaymentState)),
                9     => _paymentStateService.GetState(nameof(FailedPaymentState)),

                _ => throw new UserException($"Status uplate '{statusId}' nije podržan.")
            };
        }
    }
}
