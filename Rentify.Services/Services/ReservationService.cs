using MapsterMapper;
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

namespace Rentify.Services.Services
{
    public class ReservationService
        : BaseCRUDService<ReservationResponse, ReservationSearchObject, Reservation, ReservationUpsertRequest, ReservationUpsertRequest>,
          IReservationService
    {
        protected readonly BaseReservationState _baseState;

        public ReservationService(
            RentifyDbContext context,
            IMapper mapper,
            BaseReservationState baseState)
            : base(context, mapper)
        {
            _baseState = baseState;
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
                    || (r.Status != null && r.Status.ToLower().Contains(fts))
                    || (fts.Contains("odobreno") && r.Status == "Odobreno")
                    || ((fts.Contains("zavrseno") || fts.Contains("završeno")) && r.Status == "Završeno")
                    || ((fts.Contains("na cekanju") || fts.Contains("na čekanju")) && r.Status == "Na čekanju")
                    || ((fts.Contains("otkazano")) && r.Status == "Otkazano")
                    || ((fts.Contains("odbijeno")) && r.Status == "Odbijeno"));
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

            if (!string.IsNullOrWhiteSpace(search.Status))
            {
                var status = search.Status.Trim().ToLower();

                query = query.Where(r =>
                    r.Status != null &&
                    r.Status.ToLower() == status);
            }

            return base.ApplyFilter(query, search);
        }

        protected override IQueryable<Reservation> AddInclude(IQueryable<Reservation> query, ReservationSearchObject search)
        {
            if (search.IncludeUser == true)
            {
                query = query.Include(p => p.User);
            }

            if (search.IncludeProperty == true)
            {
                query = query.Include(p => p.Property);
            }

            return base.AddInclude(query, search);
        }

        public override async Task<ReservationResponse> CreateAsync(ReservationUpsertRequest request)
        {
            await ValidateReservationInsertAsync(request);
            var baseState = _baseState.GetState("InitialReservationState");
            return await baseState.CreateAsync(request);
        }

        protected override async Task BeforeDelete(Reservation entity)
        {
            var status = (entity.Status ?? "").Trim();

            if (status != "Otkazano" &&
                status != "Završeno" &&
                status != "Odbijeno")
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
                .Where(r => r.Status == "Odobreno")
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

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return baseState.AllowedActions(id);
        }

        private string MapStatusToState(string? status)
        {
            return (status ?? string.Empty).Trim() switch
            {
                "" => "InitialReservationState",
                "Na čekanju" => "PendingReservationState",
                "Odobreno" => "ApprovedReservationState",
                "Završeno" => "FinishedReservationState",
                "Odbijeno" => "RejectedReservationState",
                "Otkazano" => "CancelledReservationState",
                _ => throw new UserException($"Nepoznat status rezervacije: {status}")
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
                        r.Status == "Na čekanju");

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
                        r.Status == "Odobreno");

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
                    .Where(r => r.Status == "Na čekanju" || r.Status == "Odobreno")
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
                        r.Status == "Na čekanju");

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
                    .Where(r => r.Status == "Odobreno")
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
                    .Where(r => r.Status == "Odobreno")
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
                    .Where(r => r.Status == "Odobreno")
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
                .Where(a => a.Status == "Odobreno")
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

        public async Task<ReservationResponse> ApproveAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return await baseState.ToApprovedAsync(id);
        }

        public async Task<ReservationResponse> FinishAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return await baseState.ToFinishedAsync(id);
        }

        public async Task<ReservationResponse> RejectAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return await baseState.ToRejectedAsync(id);
        }

        public async Task<ReservationResponse> CancelAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return await baseState.ToCancelledAsync(id);
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
                .Where(r => r.Status == "Odobreno")
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

                for (var day = start; day <= end; day = day.AddDays(1))
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
