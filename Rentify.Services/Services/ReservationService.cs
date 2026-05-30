using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using Rentify.Services.ReservationStateMachine;

using System;
using System.Linq;
using System.Security.Claims;

namespace Rentify.Services.Services
{
    public class ReservationService
        : BaseCRUDService<ReservationResponse, ReservationSearchObject, Reservation, ReservationUpsertRequest, ReservationUpsertRequest>,
          IReservationService
    {
        protected readonly BaseReservationState _baseState;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly INotificationService _notificationService;

        public ReservationService(
            RentifyDbContext context,
            IMapper mapper,
            BaseReservationState baseState,
            IHttpContextAccessor httpContextAccessor,
            INotificationService notificationService)
            : base(context, mapper)
        {
            _baseState = baseState;
            _httpContextAccessor = httpContextAccessor;
            _notificationService = notificationService;
        }

        private int? GetLoggedInUserId()
        {
            var claim = _httpContextAccessor.HttpContext?.User
                .FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : null;
        }

        private bool IsAdmin()
        {
            return _httpContextAccessor.HttpContext?.User.IsInRole("Admin") ?? false;
        }

        protected override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
        {
            if (search.OwnerId.HasValue)
            {
                query = query.Where(x => x.Property.UserId == search.OwnerId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = string.Join(" ", search.FTS.Trim().ToLower().Split(' ', StringSplitOptions.RemoveEmptyEntries));

                query = query.Where(r =>
                    (r.Property != null && r.Property.Name.ToLower().Contains(fts))
                    || (r.User != null && r.User.FirstName.ToLower().Contains(fts))
                    || (r.User != null && r.User.LastName.ToLower().Contains(fts))
                    || (r.User != null && (r.User.FirstName + " " + r.User.LastName).ToLower().Contains(fts))
                    || (r.User != null && (r.User.LastName + " " + r.User.FirstName).ToLower().Contains(fts))
                    || (fts.Contains("najamnina") && r.IsMonthly)
                    || (fts.Contains("kratki boravak") && !r.IsMonthly)
                    || (r.Status != null && r.Status.Name.ToLower().Contains(fts))
                    || (fts.Contains("odobreno") && r.StatusId == 2)
                    || ((fts.Contains("zavrseno") || fts.Contains("završeno")) && r.StatusId == 3)
                    || ((fts.Contains("na cekanju") || fts.Contains("na čekanju")) && r.StatusId == 1)
                    || (fts.Contains("otkazano") && r.StatusId == 5)
                    || (fts.Contains("odbijeno") && r.StatusId == 4));
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.PropertyId.HasValue)
            {
                query = query.Where(r => r.PropertyId == search.PropertyId.Value);
            }

            if (search.IsMonthly.HasValue)
            {
                query = query.Where(r => r.IsMonthly == search.IsMonthly.Value);
            }

            if (search.StatusId.HasValue)
                query = query.Where(r => r.StatusId == search.StatusId.Value);

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Reservation> AddInclude(IQueryable<Reservation> query, ReservationSearchObject search)
        {
            query = query.Include(r => r.Status);

            if (search.IncludeUser == true)
                query = query.Include(p => p.User);

            if (search.IncludeProperty == true)
                query = query.Include(p => p.Property).ThenInclude(p => p.City)
                             .Include(p => p.Property).ThenInclude(p => p.BuildingType);

            return base.AddInclude(query, search);
        }

        public override async Task<ReservationResponse> CreateAsync(ReservationUpsertRequest request)
        {
            await ValidateReservationInsertAsync(request);
            var baseState = _baseState.GetState("InitialReservationState");
            var result = await baseState.CreateAsync(request);

            var property = await _context.Properties.FindAsync(request.PropertyId);
            if (property != null)
            {
                await _notificationService.CreateForUserAsync(
                    property.UserId,
                    "Nova rezervacija",
                    $"Primili ste novi zahtjev za rezervaciju nekretnine '{property.Name}'.",
                    type: "new_reservation",
                    referenceType: "reservation",
                    referenceId: result.Id
                );
            }

            return result;
        }

        protected override async Task BeforeDelete(Reservation entity)
        {
            if (entity.StatusId != 5 &&
                entity.StatusId != 3 &&
                entity.StatusId != 4)
            {
                throw new UserException(
                    "Brisanje je dozvoljeno samo za rezervacije sa statusom 'Otkazano', 'Završeno' ili 'Odbijeno'."
                );
            }

            await base.BeforeDelete(entity);
        }

        public async Task<UnavailableDatesResponse> GetUnavailableReservationMonthsAsync(
    int propertyId,
    DateTime? from = null,
    DateTime? to = null)
        {
            var fromUtc = DateTime.SpecifyKind(
                (from ?? DateTime.UtcNow).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var toUtc = DateTime.SpecifyKind(
                (to ?? DateTime.UtcNow.AddYears(2)).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var reservations = await _context.Reservations
                .AsNoTracking()
                .Where(r => r.PropertyId == propertyId)
                .Where(r => r.IsMonthly == true)
                .Where(r => r.StatusId == 2)
                .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                .Where(r =>
                    r.StartDateOfRenting!.Value.Date <= toUtc &&
                    r.EndDateOfRenting!.Value.Date >= fromUtc)
                .Select(r => new
                {
                    Start = r.StartDateOfRenting!.Value,
                    End = r.EndDateOfRenting!.Value
                })
                .ToListAsync();

            var unavailableMonths = new List<DateTime>();

            foreach (var reservation in reservations)
            {
                var start = reservation.Start.ToUniversalTime();
                var end = reservation.End.ToUniversalTime();

                var currentMonth = new DateTime(start.Year, start.Month, 1, 0, 0, 0, DateTimeKind.Utc);
                var lastMonth = new DateTime(end.Year, end.Month, 1, 0, 0, 0, DateTimeKind.Utc);

                if (currentMonth < new DateTime(fromUtc.Year, fromUtc.Month, 1, 0, 0, 0, DateTimeKind.Utc))
                {
                    currentMonth = new DateTime(fromUtc.Year, fromUtc.Month, 1, 0, 0, 0, DateTimeKind.Utc);
                }

                var toMonth = new DateTime(toUtc.Year, toUtc.Month, 1, 0, 0, 0, DateTimeKind.Utc);
                if (lastMonth > toMonth)
                {
                    lastMonth = toMonth;
                }

                while (currentMonth <= lastMonth)
                {
                    unavailableMonths.Add(currentMonth);
                    currentMonth = currentMonth.AddMonths(1);
                }
            }

            var distinctMonths = unavailableMonths
                .Distinct()
                .OrderBy(x => x)
                .ToList();

            return new UnavailableDatesResponse
            {
                PropertyId = propertyId,
                Dates = distinctMonths
            };
        }

     
        public override Task<ReservationResponse?> UpdateAsync(int id, ReservationUpsertRequest request)
        {
            throw new InvalidOperationException("Metoda nije implementirana");
        }

        public List<string> AllowedActions(int id)
        {
            if (id <= 0)
            {
                var initialState = _baseState.GetState("InitialReservationState");
                return initialState.AllowedActions(id);
            }

            var entity = _context.Reservations.Find(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            var stateName = MapStatusToState(entity.StatusId);
            var baseState = _baseState.GetState(stateName);

            return baseState.AllowedActions(id);
        }

        private static string MapStatusToState(int statusId)
        {
            return statusId switch
            {
                0                    => "InitialReservationState",
                1    => "PendingReservationState",
                2   => "ApprovedReservationState",
                3   => "FinishedReservationState",
                4   => "RejectedReservationState",
                5  => "CancelledReservationState",
                _ => throw new UserException($"Nepoznat status rezervacije: {statusId}")
            };
        }

        public async Task ValidateReservationInsertAsync(ReservationUpsertRequest request)
        {
            if (request.UserId <= 0)
                throw new UserException("Korisnik je obavezan.");

            if (request.PropertyId <= 0)
                throw new UserException("Nekretnina je obavezna.");

            if (!request.StartDateOfRenting.HasValue || !request.EndDateOfRenting.HasValue)
                throw new UserException("Početni i završni datum su obavezni.");

            var start = request.StartDateOfRenting.Value;
            var end = request.EndDateOfRenting.Value;

            if (end <= start)
                throw new UserException("Datum završetka mora biti nakon datuma početka.");

            if (request.IsMonthly)
            {
                var hasPendingMonthlyForSameUserAndProperty = await _context.Reservations
                    .AsNoTracking()
                    .AnyAsync(r =>
                        r.UserId == request.UserId &&
                        r.PropertyId == request.PropertyId &&
                        r.IsMonthly == true &&
                        r.StatusId == 1);

                if (hasPendingMonthlyForSameUserAndProperty)
                {
                    throw new UserException(
                        "Ne možete poslati novu najamninu jer već imate najamninu na čekanju za ovu nekretninu."
                    );
                }

                var hasApprovedMonthlyForSameUserAndProperty = await _context.Reservations
                    .AsNoTracking()
                    .AnyAsync(r =>
                        r.UserId == request.UserId &&
                        r.PropertyId == request.PropertyId &&
                        r.IsMonthly == true &&
                        r.StatusId == 2);

                if (hasApprovedMonthlyForSameUserAndProperty)
                {
                    throw new UserException(
                        "Ne možete poslati novu najamninu jer već imate aktivnu najamninu za ovu nekretninu."
                    );
                }

                var hasMonthlyConflictForSameUserOnDifferentProperty = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.UserId == request.UserId)
                    .Where(r => r.PropertyId != request.PropertyId)
                    .Where(r => r.IsMonthly == true)
                    .Where(r => r.StatusId == 1 || r.StatusId == 2)
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start <= r.EndDateOfRenting!.Value &&
                        end >= r.StartDateOfRenting!.Value
                    );

                if (hasMonthlyConflictForSameUserOnDifferentProperty)
                {
                    throw new UserException(
                        "Ne možete rezervisati najamninu za ovaj period jer već imate najamninu za drugu nekretninu u istom periodu."
                    );
                }
            }
            else
            {
                var hasPendingShortStayForSameUserAndProperty = await _context.Reservations
                    .AsNoTracking()
                    .AnyAsync(r =>
                        r.UserId == request.UserId &&
                        r.PropertyId == request.PropertyId &&
                        r.IsMonthly == false &&
                        r.StatusId == 1);

                if (hasPendingShortStayForSameUserAndProperty)
                {
                    throw new UserException(
                        "Ne možete poslati novi kratki boravak jer već imate kratki boravak na čekanju za ovu nekretninu."
                    );
                }
            }

            if (!request.IsMonthly)
            {
                var hasApprovedShortStayConflict = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.PropertyId == request.PropertyId)
                    .Where(r => r.IsMonthly == false)
                    .Where(r => r.StatusId == 2)
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start < r.EndDateOfRenting!.Value &&
                        end > r.StartDateOfRenting!.Value
                    );

                if (hasApprovedShortStayConflict)
                {
                    throw new UserException(
                        "Rezervacija se ne može kreirati jer ova nekretnina već ima odobren kratki boravak u tom periodu."
                    );
                }
            }

            if (request.IsMonthly)
            {
                var hasApprovedMonthlyConflict = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.PropertyId == request.PropertyId)
                    .Where(r => r.IsMonthly == true)
                    .Where(r => r.StatusId == 2)
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start <= r.EndDateOfRenting!.Value &&
                        end >= r.StartDateOfRenting!.Value
                    );

                if (hasApprovedMonthlyConflict)
                {
                    throw new UserException(
                        "Najamnina se ne može kreirati jer ova nekretnina već ima odobrenu najamninu u odabranom periodu."
                    );
                }

                var hasApprovedShortStayConflictForMonthly = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.PropertyId == request.PropertyId)
                    .Where(r => r.IsMonthly == false)
                    .Where(r => r.StatusId == 2)
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start < r.EndDateOfRenting!.Value &&
                        end > r.StartDateOfRenting!.Value
                    );

                if (hasApprovedShortStayConflictForMonthly)
                {
                    throw new UserException(
                        "Najamnina se ne može kreirati jer ova nekretnina već ima odobren kratki boravak u tom periodu."
                    );
                }
            }
        }

        private static DateTime ToUtcDate(DateTime d)
        {
            return DateTime.SpecifyKind(d.Date, DateTimeKind.Utc);
        }

        public async Task<UnavailableDatesResponse> GetUnavailableAppointmentDatesAsync(
            int propertyId,
            DateTime? from = null,
            DateTime? to = null)
        {
            var fromUtc = DateTime.SpecifyKind(
                (from ?? DateTime.UtcNow).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var toUtc = DateTime.SpecifyKind(
                (to ?? DateTime.UtcNow.AddMonths(12)).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var dateTimes = await _context.Appointments
                .AsNoTracking()
                .Where(a => a.PropertyId == propertyId)
                .Where(a => a.StatusId == 2)
                .Where(a => a.DateAppointment != null)
                .Where(a => a.DateAppointment!.Value >= fromUtc &&
                            a.DateAppointment!.Value < toUtc)
                .Select(a => a.DateAppointment!.Value)
                .Distinct()
                .OrderBy(x => x)
                .ToListAsync();

            return new UnavailableDatesResponse
            {
                PropertyId = propertyId,
                Dates = dateTimes
            };
        }

        private void AddHistory(int reservationId, int oldStatusId, int newStatusId, string? reason = null)
        {
            var loggedInId = GetLoggedInUserId();
            var note = loggedInId.HasValue
                ? $"Promijenio: userId={loggedInId}"
                : null;

            _context.ReservationHistories.Add(new ReservationHistory
            {
                ReservationId = reservationId,
                StatusId = newStatusId,
                OldStatusId = oldStatusId,
                NewStatusId = newStatusId,
                ChangedByUserId = loggedInId,
                Reason = reason,
                Note = note,
                ChangedAt = DateTime.UtcNow
            });
        }

        private async Task CheckPropertyOwnershipAsync(int reservationId)
        {
            if (IsAdmin()) return;

            var loggedInId = GetLoggedInUserId()
                ?? throw new ForbiddenException("Korisnik nije autentificiran.");

            var propertyUserId = await _context.Reservations
                .Where(r => r.Id == reservationId)
                .Include(r => r.Property)
                .Select(r => r.Property!.UserId)
                .FirstOrDefaultAsync();

            if (propertyUserId != loggedInId)
                throw new ForbiddenException("Nemate pravo mijenjati rezervaciju za tuđu nekretninu.");
        }

        private async Task NotifyReservationUserAsync(int userId, int reservationId, string title, string message)
        {
            await _notificationService.CreateForUserAsync(
                userId,
                title,
                message,
                type: "reservation_status",
                referenceType: "reservation",
                referenceId: reservationId
            );
        }

        public async Task<ReservationResponse> ApproveAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            await CheckPropertyOwnershipAsync(id);

            var oldStatusId = entity.StatusId;
            var stateName = MapStatusToState(oldStatusId);
            var baseState = _baseState.GetState(stateName);

            var result = await baseState.ToApprovedAsync(id);
            AddHistory(id, oldStatusId, 2);
            await NotifyReservationUserAsync(
                entity.UserId,
                id,
                "Rezervacija odobrena",
                "Vasa rezervacija je odobrena."
            );
            await _context.SaveChangesAsync();
            return result;
        }

        public async Task<ReservationResponse> FinishAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            await CheckPropertyOwnershipAsync(id);

            var oldStatusId = entity.StatusId;
            var stateName = MapStatusToState(oldStatusId);
            var baseState = _baseState.GetState(stateName);

            var result = await baseState.ToFinishedAsync(id);
            AddHistory(id, oldStatusId, 3);
            await NotifyReservationUserAsync(
                entity.UserId,
                id,
                "Rezervacija zavrsena",
                "Vasa rezervacija je oznacena kao zavrsena."
            );
            await _context.SaveChangesAsync();
            return result;
        }

        public async Task<ReservationResponse> RejectAsync(int id, string? reason = null)
        {
            var entity = await _context.Reservations.FindAsync(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            await CheckPropertyOwnershipAsync(id);

            var oldStatusId = entity.StatusId;
            var stateName = MapStatusToState(oldStatusId);
            var baseState = _baseState.GetState(stateName);

            var result = await baseState.ToRejectedAsync(id);
            AddHistory(id, oldStatusId, 4, reason);
            await NotifyReservationUserAsync(
                entity.UserId,
                id,
                "Rezervacija odbijena",
                string.IsNullOrWhiteSpace(reason)
                    ? "Vasa rezervacija je odbijena."
                    : $"Vasa rezervacija je odbijena. Razlog: {reason}"
            );
            await _context.SaveChangesAsync();
            return result;
        }

        public async Task<ReservationResponse> CancelAsync(int id, string? reason = null)
        {
            var entity = await _context.Reservations.FindAsync(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            var oldStatusId = entity.StatusId;
            var stateName = MapStatusToState(oldStatusId);
            var baseState = _baseState.GetState(stateName);

            var result = await baseState.ToCancelledAsync(id);
            AddHistory(id, oldStatusId, 5, reason);
            await NotifyReservationUserAsync(
                entity.UserId,
                id,
                "Rezervacija otkazana",
                string.IsNullOrWhiteSpace(reason)
                    ? "Rezervacija je otkazana."
                    : $"Rezervacija je otkazana. Razlog: {reason}"
            );
            await _context.SaveChangesAsync();
            return result;
        }

        public async Task<UnavailableDatesResponse> GetUnavailableReservationDatesAsync(
            int propertyId,
            DateTime? from = null,
            DateTime? to = null)
        {
            var fromUtc = DateTime.SpecifyKind(
                (from ?? DateTime.UtcNow).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var toUtc = DateTime.SpecifyKind(
                (to ?? DateTime.UtcNow.AddMonths(12)).ToUniversalTime().Date,
                DateTimeKind.Utc);

            var reservations = await _context.Reservations
                .AsNoTracking()
                .Where(r => r.PropertyId == propertyId)
                .Where(r => r.IsMonthly == false)
                .Where(r => r.StatusId == 2)
                .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                .Where(r =>
                    r.StartDateOfRenting!.Value.Date <= toUtc &&
                    r.EndDateOfRenting!.Value.Date >= fromUtc)
                .Select(r => new
                {
                    Start = r.StartDateOfRenting!.Value,
                    End = r.EndDateOfRenting!.Value
                })
                .ToListAsync();

            var unavailableDates = new List<DateTime>();

            foreach (var reservation in reservations)
            {
                var start = reservation.Start.ToUniversalTime().Date;
                var end = reservation.End.ToUniversalTime().Date;

                if (start < fromUtc)
                    start = fromUtc;

                if (end > toUtc)
                    end = toUtc;

                for (var day = start; day < end; day = day.AddDays(1))
                {
                    unavailableDates.Add(DateTime.SpecifyKind(day, DateTimeKind.Utc));
                }
            }

            var distinctDates = unavailableDates
                .Distinct()
                .OrderBy(x => x)
                .ToList();

            return new UnavailableDatesResponse
            {
                PropertyId = propertyId,
                Dates = distinctDates
            };
        }
    }
}
