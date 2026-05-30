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
        private readonly INotificationService _notificationService;

        public AppointmentService(
            RentifyDbContext context,
            IMapper mapper,
            BaseAppointmentState baseState,
            INotificationService notificationService
        ) : base(context, mapper)
        {
            _baseState = baseState;
            _notificationService = notificationService;
        }

        protected override IQueryable<Appointment> AddInclude(IQueryable<Appointment> query, AppointmentSearchObject search)
        {
            query = query.Include(a => a.Status);

            if (search.IncludeProperty == true)
                query = query.Include(p => p.Property).ThenInclude(p => p.City)
                             .Include(p => p.Property).ThenInclude(p => p.BuildingType);

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

            if (search.StatusId.HasValue)
                query = query.Where(x => x.StatusId == search.StatusId.Value);

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
                    || (a.Status != null && a.Status.Name.ToLower().Contains(fts))
                    || (fts.Contains("odobreno") && a.StatusId == 2)
                    || (fts.Contains("odbijeno") && a.StatusId == 4)
                    || ((fts.Contains("na čekanju") || fts.Contains("na cekanju")) && a.StatusId == 1)
                    || (fts.Contains("otkazano") && a.StatusId == 5)
                    || ((fts.Contains("završeno") || fts.Contains("zavrseno")) && a.StatusId == 3)
                );
            }

            return query;
        }

        public override async Task<AppointmentResponse> CreateAsync(AppointmentUpsertRequest request)
        {
            await ValidateAppointmentsAsync(request);
            var baseState = _baseState.GetState(nameof(InitialAppointmentState));
            var result = await baseState.CreateAsync(request);

            var property = await _context.Properties.FindAsync(request.PropertyId);
            if (property != null)
            {
                await _notificationService.CreateForUserAsync(
                    property.UserId,
                    "Novi zahtjev za termin",
                    $"Korisnik je zahtijevao termin za nekretninu '{property.Name}'.",
                    type: "new_appointment",
                    referenceType: "appointment",
                    referenceId: result.Id
                );
            }

            return result;
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
                    (x.StatusId == 1 || x.StatusId == 2) &&
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
                    (x.StatusId == 1 || x.StatusId == 2)
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
                    x.StatusId == 2 &&
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

            var requestedStatusId = request.StatusId;
            var currentStatusId = entity.StatusId;

            var stateName = MapStatusToState(currentStatusId);
            var baseState = _baseState.GetState(stateName);

            if (requestedStatusId == 0 || requestedStatusId == currentStatusId)
                return await baseState.UpdateAsync(id, request);

            return requestedStatusId switch
            {
                2  => await baseState.ToApprovedAsync(id),
                3  => await baseState.ToFinishedAsync(id),
                4  => await baseState.ToRejectedAsync(id),
                5 => await baseState.ToCancelledAsync(id),
                _ => throw new UserException("Nepodržana promjena statusa.")
            };
        }

        public async Task<AppointmentResponse> ApproveAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.StatusId);
            var baseState = _baseState.GetState(stateName);
            var result = await baseState.ToApprovedAsync(id);

            await _notificationService.CreateForUserAsync(
                entity.UserId,
                "Termin odobren",
                "Vaš zahtjev za termin je odobren.",
                type: "appointment_status",
                referenceType: "appointment",
                referenceId: id
            );

            return result;
        }

        public async Task<AppointmentResponse> FinishAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.StatusId);
            var baseState = _baseState.GetState(stateName);
            var result = await baseState.ToFinishedAsync(id);

            await _notificationService.CreateForUserAsync(
                entity.UserId,
                "Termin završen",
                "Vaš termin je označen kao završen.",
                type: "appointment_status",
                referenceType: "appointment",
                referenceId: id
            );

            return result;
        }

        public async Task<AppointmentResponse> RejectAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.StatusId);
            var baseState = _baseState.GetState(stateName);
            var result = await baseState.ToRejectedAsync(id);

            await _notificationService.CreateForUserAsync(
                entity.UserId,
                "Termin odbijen",
                "Vaš zahtjev za termin je odbijen.",
                type: "appointment_status",
                referenceType: "appointment",
                referenceId: id
            );

            return result;
        }

        public async Task<AppointmentResponse> CancelAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.StatusId);
            var baseState = _baseState.GetState(stateName);
            var result = await baseState.ToCancelledAsync(id);

            await _notificationService.CreateForUserAsync(
                entity.UserId,
                "Termin otkazan",
                "Vaš termin je otkazan.",
                type: "appointment_status",
                referenceType: "appointment",
                referenceId: id
            );

            return result;
        }

        public List<string> AllowedActions(int id)
        {
            var entity = _context.Appointments.Find(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            var stateName = MapStatusToState(entity.StatusId);
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
                .Where(a => a.StatusId == 2)
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
            if (entity.StatusId != 4 && entity.StatusId != 3)
            {
                throw new UserException(
                    "Brisanje je dozvoljeno samo za termine sa statusom 'Odbijeno' ili 'Završeno'."
                );
            }

            await base.BeforeDelete(entity);
        }

        private static string MapStatusToState(int statusId)
        {
            return statusId switch
            {
                1   => nameof(PendingAppointmentState),
                2  => nameof(ApprovedAppointmentState),
                4  => nameof(RejectedAppointmentState),
                5 => nameof(CancelledAppointmentState),
                3  => nameof(FinishedAppointmentState),
                _                   => nameof(InitialAppointmentState)
            };
        }
    }
}
