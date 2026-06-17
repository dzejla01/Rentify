using MapsterMapper;
using Microsoft.AspNetCore.Http;
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
using System.Security.Claims;

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
        private readonly IHttpContextAccessor _httpContextAccessor;

        public PaymentService(
            RentifyDbContext context,
            IStripeService stripeService,
            IDeviceTokenService deviceToken,
            PushNotificationService push,
            IMapper mapper,
            IOptions<AppConfig> config,
            BasePaymentState paymentStateService,
            ILogger<PaymentService> logger,
            INotificationService notificationService,
            IHttpContextAccessor httpContextAccessor
        ) : base(context, mapper)
        {
            _deviceTokenService = deviceToken;
            _pushService = push;
            _stripeService = stripeService;
            _config = config.Value;
            _paymentStateService = paymentStateService;
            _logger = logger;
            _notificationService = notificationService;
            _httpContextAccessor = httpContextAccessor;
        }

        private int? GetLoggedInUserId()
        {
            var claim = _httpContextAccessor.HttpContext?.User
                .FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }

        private bool IsAdmin()
            => _httpContextAccessor.HttpContext?.User.IsInRole("Admin") ?? false;

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
                    .ThenInclude(r => r.Property)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (entity == null) return null;
            return MapToResponse(entity);
        }

        private async Task ResolveExpiredPaymentDeadlinesAsync(int? paymentId = null)
        {
            var now = DateTime.UtcNow;

            // Upozorenje za kasnjenje: WarningDateToPay prošlo, SecondWarningDate još nije
            var firstWarnQuery = _context.Payments
                .Include(p => p.Reservation)
                    .ThenInclude(r => r.Property)
                .Include(p => p.Reservation)
                    .ThenInclude(r => r.User)
                .Where(p => p.WarningDateToPay != null)
                .Where(p => p.WarningDateToPay!.Value <= now)
                .Where(p => p.SecondWarningDate == null || p.SecondWarningDate!.Value > now)
                .Where(p =>
                    p.StatusId == PaymentStatus.Pending ||
                    p.StatusId == PaymentStatus.Processing);

            if (paymentId.HasValue)
                firstWarnQuery = firstWarnQuery.Where(p => p.Id == paymentId.Value);

            var firstWarnPayments = await firstWarnQuery.ToListAsync();

            foreach (var payment in firstWarnPayments)
            {
                if (payment.Reservation?.Property == null) continue;

                // Dedulikacija: ne slati upozorenje ako je već poslano za ovaj payment
                var alreadySent = await _context.AppNotifications
                    .AnyAsync(n =>
                        n.ReferenceType == "payment" &&
                        n.ReferenceId == payment.Id &&
                        n.Type == "payment_first_warning");

                if (alreadySent) continue;

                var propertyName = payment.Reservation.Property.Name;
                var tenantName = payment.Reservation.User != null
                    ? $"{payment.Reservation.User.FirstName} {payment.Reservation.User.LastName}"
                    : $"Korisnik #{payment.Reservation.UserId}";

                // Obavijest stanaru
                await _notificationService.CreateForUserAsync(
                    payment.Reservation.UserId,
                    "Upozorenje: rok za plaćanje uskoro ističe",
                    $"Rok za plaćanje za nekretninu '{propertyName}' uskoro ističe. Molimo platite na vrijeme kako biste izbjegli otkazivanje rezervacije.",
                    type: "payment_first_warning",
                    referenceType: "payment",
                    referenceId: payment.Id
                );

                // Obavijest vlasniku o kasnjenju
                await _notificationService.CreateForUserAsync(
                    payment.Reservation.Property.UserId,
                    "Kasnjenje plaćanja",
                    $"Korisnik {tenantName} kasni sa plaćanjem za nekretninu '{propertyName}'.",
                    type: "payment_first_warning",
                    referenceType: "payment",
                    referenceId: payment.Id
                );
            }

            // Automatsko otkazivanje: SecondWarningDate prošlo
            var expiredQuery = _context.Payments
                .Include(p => p.Reservation)
                    .ThenInclude(r => r.Property)
                .Include(p => p.Reservation)
                    .ThenInclude(r => r.User)
                .Where(p => p.SecondWarningDate != null)
                .Where(p => p.SecondWarningDate!.Value <= now)
                .Where(p =>
                    p.StatusId == PaymentStatus.Pending ||
                    p.StatusId == PaymentStatus.Processing);

            if (paymentId.HasValue)
                expiredQuery = expiredQuery.Where(p => p.Id == paymentId.Value);

            var expiredPayments = await expiredQuery.ToListAsync();

            if (!expiredPayments.Any() && !firstWarnPayments.Any())
                return;

            foreach (var payment in expiredPayments)
            {
                payment.StatusId = PaymentStatus.Unpaid;
                payment.PaidAt = null;

                if (payment.Reservation != null &&
                    payment.Reservation.StatusId != ReservationAppointmentStatus.Cancelled &&
                    payment.Reservation.StatusId != ReservationAppointmentStatus.Finished &&
                    payment.Reservation.StatusId != ReservationAppointmentStatus.Rejected)
                {
                    var oldReservationStatusId = payment.Reservation.StatusId;
                    payment.Reservation.StatusId = ReservationAppointmentStatus.Cancelled;

                    _context.ReservationHistories.Add(new ReservationHistory
                    {
                        ReservationId = payment.Reservation.Id,
                        StatusId = ReservationAppointmentStatus.Cancelled,
                        OldStatusId = oldReservationStatusId,
                        NewStatusId = ReservationAppointmentStatus.Cancelled,
                        ChangedByUserId = null,
                        Reason = "Automatski otkazano - rok za plaćanje je istekao.",
                        Note = $"Sistemska akcija (payment Id={payment.Id}).",
                        ChangedAt = now
                    });

                    var propertyName = payment.Reservation.Property?.Name ?? "nekretnina";
                    var tenantName = payment.Reservation.User != null
                        ? $"{payment.Reservation.User.FirstName} {payment.Reservation.User.LastName}"
                        : $"Korisnik #{payment.Reservation.UserId}";

                    // Obavijest stanaru
                    await _notificationService.CreateForUserAsync(
                        payment.Reservation.UserId,
                        "Rezervacija otkazana",
                        $"Vaša rezervacija za nekretninu '{propertyName}' je automatski otkazana jer rok za plaćanje nije ispoštovan.",
                        type: "reservation_status",
                        referenceType: "reservation",
                        referenceId: payment.Reservation.Id
                    );

                    // Obavijest vlasniku o kašnjenju i automatskom otkazivanju
                    if (payment.Reservation.Property != null)
                    {
                        await _notificationService.CreateForUserAsync(
                            payment.Reservation.Property.UserId,
                            "Korisnik zakasnio sa uplatom",
                            $"Korisnik {tenantName} je zakasnio sa uplatom za nekretninu '{propertyName}'. Rezervacija je automatski otkazana.",
                            type: "payment_expired",
                            referenceType: "reservation",
                            referenceId: payment.Reservation.Id
                        );
                    }
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
                    || (fts.Contains("plaćeno") && x.StatusId == PaymentStatus.Paid)
                    || (fts.Contains("placeno") && x.StatusId == PaymentStatus.Paid)
                    || (fts.Contains("na čekanju") && x.StatusId == PaymentStatus.Pending)
                    || (fts.Contains("na cekanju") && x.StatusId == PaymentStatus.Pending)
                    || (fts.Contains("procesiranje") && x.StatusId == PaymentStatus.Processing)
                    || (fts.Contains("neplaćeno") && x.StatusId == PaymentStatus.Unpaid)
                    || (fts.Contains("neplaceno") && x.StatusId == PaymentStatus.Unpaid)
                    || (fts.Contains("otkazano") && x.StatusId == PaymentStatus.Cancelled)
                    || (fts.Contains("neuspješno") && x.StatusId == PaymentStatus.Failed)
                    || (fts.Contains("neuspjesno") && x.StatusId == PaymentStatus.Failed)
                );
            }

            if (search.ReservationId.HasValue)
                query = query.Where(x => x.ReservationId == search.ReservationId.Value);

            if (search.UserId.HasValue)
                query = query.Where(x => x.Reservation != null && x.Reservation.UserId == search.UserId.Value);

            if (search.OwnerId.HasValue)
                query = query.Where(x => x.Reservation != null && x.Reservation.Property != null && x.Reservation.Property.UserId == search.OwnerId.Value);

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
            var reservation = await _context.Reservations
                .Include(r => r.Property)
                .FirstOrDefaultAsync(r => r.Id == entity.ReservationId);

            if (reservation == null)
                throw new NotFoundException("Rezervacija ne postoji.");

            if (!IsAdmin())
            {
                var loggedInId = GetLoggedInUserId()
                    ?? throw new ForbiddenException("Korisnik nije autentificiran.");

                if (reservation.Property == null || reservation.Property.UserId != loggedInId)
                    throw new ForbiddenException("Možete kreirati uplate samo za rezervacije na vlastitim nekretninama.");
            }

            if (reservation.StatusId != ReservationAppointmentStatus.Approved)
                throw new UserException("Uplata se može kreirati samo za odobrenu rezervaciju.");

            var duplicateExists = await _context.Payments.AnyAsync(p =>
                p.ReservationId == entity.ReservationId &&
                p.MonthNumber == entity.MonthNumber &&
                p.YearNumber == entity.YearNumber);

            if (duplicateExists)
                throw new InvalidOperationException("Uplata za ovaj mjesec i godinu već postoji za ovu rezervaciju.");

            // Ručno kreiranje uvijek kreće kao 'Na čekanju' — status se dalje mijenja
            // isključivo kroz Stripe webhook tok ili admin Update, nikad direktno iz Create requesta.
            entity.StatusId = PaymentStatus.Pending;
            entity.PaidAt = null;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Payment entity, PaymentUpsertRequest request)
        {
            var newStatusId = request.StatusId != 0 ? request.StatusId : entity.StatusId;

            if (newStatusId == PaymentStatus.Paid && entity.PaidAt == null)
                entity.PaidAt = DateTime.UtcNow;

            if (newStatusId != PaymentStatus.Paid)
                entity.PaidAt = null;

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task AfterInsert(Payment entity, PaymentUpsertRequest request)
        {
            if (entity.StatusId != PaymentStatus.Pending)
                return;

            var reservationData = await _context.Reservations
                .Where(x => x.Id == entity.ReservationId)
                .Select(x => new { x.UserId, PropertyName = x.Property != null ? x.Property.Name : "" })
                .FirstOrDefaultAsync();

            if (reservationData == null || reservationData.UserId == 0)
                return;

            var reservationUserId = reservationData.UserId;
            var propertyName = string.IsNullOrEmpty(reservationData.PropertyName) ? "nekretnina" : reservationData.PropertyName;

            await _notificationService.CreateForUserAsync(
                reservationUserId,
                "Novi zahtjev za plaćanje",
                $"Imate novi zahtjev za plaćanje za nekretninu '{propertyName}'.",
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
                    $"Imate novi zahtjev za plaćanje za nekretninu '{propertyName}'.",
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

            if (payment.StatusId == PaymentStatus.Paid)
                throw new UserException("Uplata je već plaćena.");

            if (payment.StatusId == PaymentStatus.Processing && !string.IsNullOrWhiteSpace(payment.StripePaymentIntentId))
                throw new UserException("Plaćanje je već u toku. Sačekajte završetak tekuće transakcije.");

            if (payment.StatusId == PaymentStatus.Cancelled)
                throw new UserException("Uplata je otkazana.");

            if (payment.StatusId == PaymentStatus.Unpaid)
                throw new UserException("Uplata je označena kao neplaćena.");

            if (payment.StatusId == PaymentStatus.Failed)
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

            if (payment.StatusId == PaymentStatus.Paid)
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
            else if (payment.StripePaymentIntentId != paymentIntentId)
            {
                // Webhook event pripada starom/napuštenom intentu koji više nije aktivan
                // za ovaj payment (npr. korisnik je pokrenuo novi pokušaj plaćanja) — odbij ga.
                _logger.LogWarning(
                    "Odbijen webhook za payment {PaymentId}: intent {IncomingIntent} ne odgovara aktivnom intentu {ActiveIntent}.",
                    payment.Id, paymentIntentId, payment.StripePaymentIntentId);
                return null;
            }

            return payment;
        }

        private BasePaymentState GetPaymentStateForStatus(int statusId)
        {
            return statusId switch
            {
                PaymentStatus.Pending => _paymentStateService.GetState(nameof(PendingPaymentState)),
                PaymentStatus.Processing => _paymentStateService.GetState(nameof(ProcessingPaymentState)),
                PaymentStatus.Paid => _paymentStateService.GetState(nameof(PaidPaymentState)),
                PaymentStatus.Unpaid => _paymentStateService.GetState(nameof(UnpaidPaymentState)),
                PaymentStatus.Cancelled => _paymentStateService.GetState(nameof(CancelledPaymentState)),
                PaymentStatus.Failed => _paymentStateService.GetState(nameof(FailedPaymentState)),

                _ => throw new UserException($"Status uplate '{statusId}' nije podržan.")
            };
        }
    }
}
