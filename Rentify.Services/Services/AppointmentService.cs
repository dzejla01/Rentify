using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using Rentify.Services.AppointmentStateMachine;
using System.Linq;

namespace Rentify.Services.Services
{
    public class AppointmentService
        : BaseCRUDService<AppointmentResponse, AppointmentSearchObject, Appointment, AppointmentUpsertRequest, AppointmentUpsertRequest>,
          IAppointmentService
    {
        private readonly BaseAppointmentState _baseState;

        public AppointmentService(
            RentifyDbContext context,
            IMapper mapper,
            BaseAppointmentState baseState
        ) : base(context, mapper)
        {
            _baseState = baseState;
        }

        protected override IQueryable<Appointment> AddInclude(IQueryable<Appointment> query, AppointmentSearchObject search)
        {
            if (search.IncludeProperty == true)
                query = query.Include(p => p.Property);

            if (search.IncludeUser == true)
                query = query.Include(p => p.User);

            return base.AddInclude(query, search);
        }

        protected override IQueryable<Appointment> ApplyFilter(IQueryable<Appointment> query, AppointmentSearchObject search)
        {
            query = base.ApplyFilter(query, search);

            if (search.OwnerId.HasValue)
                query = query.Where(x => x.Property.UserId == search.OwnerId.Value);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.PropertyId.HasValue)
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);

            if (!string.IsNullOrWhiteSpace(search.Status))
                query = query.Where(x => x.Status == search.Status);

            if (search.DateFrom.HasValue)
                query = query.Where(x => x.DateAppointment >= search.DateFrom.Value);

            if (search.DateTo.HasValue)
                query = query.Where(x => x.DateAppointment <= search.DateTo.Value);

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = string.Join(" ", search.FTS.Trim().ToLower().Split(' ', StringSplitOptions.RemoveEmptyEntries));

                query = query.Where(a =>
                    (a.Property != null && a.Property.Name.ToLower().Contains(fts))
                    || (a.User != null && a.User.FirstName.ToLower().Contains(fts))
                    || (a.User != null && a.User.LastName.ToLower().Contains(fts))
                    || (a.User != null && (a.User.FirstName + " " + a.User.LastName).ToLower().Contains(fts))
                    || (a.User != null && (a.User.LastName + " " + a.User.FirstName).ToLower().Contains(fts))
                    || ((a.Status ?? "").ToLower().Contains(fts))
                    || (fts.Contains("odobreno") && a.Status == "Odobreno")
                    || (fts.Contains("odbijeno") && a.Status == "Odbijeno")
                    || ((fts.Contains("na čekanju") || fts.Contains("na cekanju")) && a.Status == "Na čekanju")
                    || (fts.Contains("otkazano") && a.Status == "Otkazano")
                    || ((fts.Contains("završeno") || fts.Contains("zavrseno")) && a.Status == "Završeno")
                );
            }

            return query;
        }

        public override async Task<AppointmentResponse> CreateAsync(AppointmentUpsertRequest request)
        {
            await ValidateAppointmentsAsync(request);
            var baseState = _baseState.GetState(nameof(InitialAppointmentState));
            return await baseState.CreateAsync(request);
        }

        private async Task ValidateAppointmentsAsync(AppointmentUpsertRequest request)
        {
            if (request.UserId <= 0)
                throw new UserException("Korisnik je obavezan.");

            if (request.PropertyId <= 0)
                throw new UserException("Nekretnina je obavezna.");

            if (!request.DateAppointment.HasValue)
                throw new UserException("Datum termina je obavezan.");

            var appointmentDate = request.DateAppointment.Value;

            if (appointmentDate <= DateTime.UtcNow)
                throw new UserException("Termin ne može biti u prošlosti.");

            var hasSameDateTimeAppointment = await _context.Appointments
                .AsNoTracking()
                .AnyAsync(x =>
                    x.UserId == request.UserId &&
                    (x.Status == "Na čekanju" || x.Status == "Odobreno") &&
                    x.DateAppointment.HasValue &&
                    x.DateAppointment.Value == appointmentDate
                );

            if (hasSameDateTimeAppointment)
            {
                throw new UserException(
                    "Već imate zakazan termin u istom datumu i vremenu."
                );
            }

            var hasSamePropertyAppointment = await _context.Appointments
                .AsNoTracking()
                .AnyAsync(x =>
                    x.UserId == request.UserId &&
                    x.PropertyId == request.PropertyId &&
                    (x.Status == "Na čekanju" || x.Status == "Odobreno")
                );

            if (hasSamePropertyAppointment)
            {
                throw new UserException(
                    "Već imate termin za ovu nekretninu koji je na čekanju ili odobren."
                );
            }

            var propertyHasApprovedAtSameTime = await _context.Appointments
                .AsNoTracking()
                .AnyAsync(x =>
                    x.PropertyId == request.PropertyId &&
                    x.Status == "Odobreno" &&
                    x.DateAppointment.HasValue &&
                    x.DateAppointment.Value == appointmentDate
                );

            if (propertyHasApprovedAtSameTime)
            {
                throw new UserException(
                    "Za ovu nekretninu već postoji odobren termin u odabranom vremenu."
                );
            }
        }

        public override async Task<AppointmentResponse?> UpdateAsync(int id, AppointmentUpsertRequest request)
        {
            var entity = await _context.Appointments.FindAsync(id);

            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var requestedStatus = (request.Status ?? "").Trim();
            var currentStatus = (entity.Status ?? "").Trim();

            var stateName = MapStatusToState(currentStatus);
            var baseState = _baseState.GetState(stateName);

            if (string.IsNullOrWhiteSpace(requestedStatus) || requestedStatus == currentStatus)
            {
                return await baseState.UpdateAsync(id, request);
            }

            return requestedStatus switch
            {
                "Odobreno" => await baseState.ToApprovedAsync(id),
                "Završeno" => await baseState.ToFinishedAsync(id),
                "Odbijeno" => await baseState.ToRejectedAsync(id),
                "Otkazano" => await baseState.ToCancelledAsync(id),
                _ => throw new UserException("Nepodržana promjena statusa.")
            };
        }

        public async Task<AppointmentResponse> ApproveAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return await baseState.ToApprovedAsync(id);
        }

        public async Task<AppointmentResponse> FinishAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return await baseState.ToFinishedAsync(id);
        }

        public async Task<AppointmentResponse> RejectAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return await baseState.ToRejectedAsync(id);
        }

        public async Task<AppointmentResponse> CancelAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return await baseState.ToCancelledAsync(id);
        }

        public List<string> AllowedActions(int id)
        {
            var entity = _context.Appointments.Find(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.Status);
            var baseState = _baseState.GetState(stateName);

            return baseState.AllowedActions(id);
        }

        public async Task<UnavailableAppointmentsResponse> GetUnavailableAppointmentDatesAsync(
            int propertyId,
            DateTime? from = null,
            DateTime? to = null)
        {
            var fromUtc = DateTime.SpecifyKind(
                (from ?? DateTime.UtcNow).ToUniversalTime().Date,
                DateTimeKind.Utc
            );

            var toUtc = DateTime.SpecifyKind(
                (to ?? DateTime.UtcNow.AddMonths(12)).ToUniversalTime().Date,
                DateTimeKind.Utc
            );

            var dates = await _context.Appointments
                .AsNoTracking()
                .Where(a => a.PropertyId == propertyId)
                .Where(a => a.Status == "Odobreno")
                .Where(a => a.DateAppointment != null)
                .Where(a => a.DateAppointment!.Value >= fromUtc && a.DateAppointment!.Value < toUtc)
                .Select(a => a.DateAppointment!.Value)
                .Distinct()
                .OrderBy(d => d)
                .ToListAsync();

            return new UnavailableAppointmentsResponse
            {
                PropertyId = propertyId,
                DateTimes = dates
            };
        }

        protected override async Task BeforeInsert(Appointment entity, AppointmentUpsertRequest request)
        {
            if (request.UserId <= 0)
                throw new UserException("Korisnik je obavezan.");

            if (request.PropertyId <= 0)
                throw new UserException("Nekretnina je obavezna.");

            if (!request.DateAppointment.HasValue)
                throw new UserException("Datum termina je obavezan.");

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeDelete(Appointment entity)
        {
            var status = (entity.Status ?? "").Trim();

            if (status != "Odbijeno" && status != "Završeno")
            {
                throw new UserException(
                    "Brisanje je dozvoljeno samo za termine sa statusom 'Odbijeno' ili 'Završeno'."
                );
            }

            await base.BeforeDelete(entity);
        }

        private string MapStatusToState(string? status)
        {
            return (status ?? "").Trim() switch
            {
                "Na čekanju" => nameof(PendingAppointmentState),
                "Odobreno" => nameof(ApprovedAppointmentState),
                "Odbijeno" => nameof(RejectedAppointmentState),
                "Otkazano" => nameof(CancelledAppointmentState),
                "Završeno" => nameof(FinishedAppointmentState),
                _ => nameof(InitialAppointmentState)
            };
        }
    }
}
