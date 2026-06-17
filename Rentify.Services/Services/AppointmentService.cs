using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.Interfaces;
using Rentify.Services.AppointmentStateMachine;
using System.Linq;
using System.Security.Claims;

namespace Rentify.Services.Services
{
    public class AppointmentService
        : BaseCRUDService<AppointmentResponse, AppointmentSearchObject, Appointment, AppointmentUpsertRequest, AppointmentUpsertRequest>,
          IAppointmentService
    {
        private readonly BaseAppointmentState _baseState;
        private readonly INotificationService _notificationService;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public AppointmentService(
            RentifyDbContext context,
            IMapper mapper,
            BaseAppointmentState baseState,
            INotificationService notificationService,
            IHttpContextAccessor httpContextAccessor
        ) : base(context, mapper)
        {
            _baseState = baseState;
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

        private async Task CheckPropertyOwnershipAsync(int appointmentId)
        {
            if (IsAdmin()) return;

            var loggedInId = GetLoggedInUserId()
                ?? throw new ForbiddenException("Korisnik nije autentificiran.");

            var propertyUserId = await _context.Appointments
                .Where(a => a.Id == appointmentId)
                .Select(a => a.Property!.UserId)
                .FirstOrDefaultAsync();

            if (propertyUserId != loggedInId)
                throw new ForbiddenException("Nemate pravo mijenjati termin za tuđu nekretninu.");
        }

        private async Task CheckCancelAuthorizationAsync(int appointmentId, int appointmentUserId)
        {
            if (IsAdmin()) return;

            var loggedInId = GetLoggedInUserId()
                ?? throw new ForbiddenException("Korisnik nije autentificiran.");

            var isVlasnik = _httpContextAccessor.HttpContext?.User.IsInRole("Vlasnik") ?? false;

            if (isVlasnik)
            {
                var propertyUserId = await _context.Appointments
                    .Where(a => a.Id == appointmentId)
                    .Select(a => a.Property!.UserId)
                    .FirstOrDefaultAsync();

                if (propertyUserId == loggedInId) return;
            }

            if (appointmentUserId == loggedInId) return;

            throw new ForbiddenException("Nemate pravo otkazati ovaj termin.");
        }

        private void AddHistory(int appointmentId, int oldStatusId, int newStatusId, string? reason = null)
        {
            var loggedInId = GetLoggedInUserId();
            var note = loggedInId.HasValue
                ? $"Promijenio: userId={loggedInId}"
                : null;

            _context.AppointmentHistories.Add(new AppointmentHistory
            {
                AppointmentId = appointmentId,
                StatusId = newStatusId,
                OldStatusId = oldStatusId,
                NewStatusId = newStatusId,
                ChangedByUserId = loggedInId,
                Reason = reason,
                Note = note,
                ChangedAt = DateTime.UtcNow
            });
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
                    || (fts.Contains("odobreno") && a.StatusId == ReservationAppointmentStatus.Approved)
                    || (fts.Contains("odbijeno") && a.StatusId == ReservationAppointmentStatus.Rejected)
                    || ((fts.Contains("na čekanju") || fts.Contains("na cekanju")) && a.StatusId == ReservationAppointmentStatus.Pending)
                    || (fts.Contains("otkazano") && a.StatusId == ReservationAppointmentStatus.Cancelled)
                    || ((fts.Contains("završeno") || fts.Contains("zavrseno")) && a.StatusId == ReservationAppointmentStatus.Finished)
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
                    (x.StatusId == ReservationAppointmentStatus.Pending || x.StatusId == ReservationAppointmentStatus.Approved) &&
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
                    (x.StatusId == ReservationAppointmentStatus.Pending || x.StatusId == ReservationAppointmentStatus.Approved)
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
                    x.StatusId == ReservationAppointmentStatus.Approved &&
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
                ReservationAppointmentStatus.Approved => await baseState.ToApprovedAsync(id),
                ReservationAppointmentStatus.Finished => await baseState.ToFinishedAsync(id),
                ReservationAppointmentStatus.Rejected => await baseState.ToRejectedAsync(id),
                ReservationAppointmentStatus.Cancelled => await baseState.ToCancelledAsync(id),
                _ => throw new UserException("Nepodržana promjena statusa.")
            };
        }

        public async Task<AppointmentResponse> ApproveAsync(int id)
        {
            var entity = await _context.Appointments
                .Include(a => a.Property)
                .FirstOrDefaultAsync(a => a.Id == id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            await CheckPropertyOwnershipAsync(id);

            var oldStatusId = entity.StatusId;
            var stateName = MapStatusToState(oldStatusId);
            var baseState = _baseState.GetState(stateName);
            var result = await baseState.ToApprovedAsync(id);
            AddHistory(id, oldStatusId, ReservationAppointmentStatus.Approved);
            await _context.SaveChangesAsync();

            var propertyName = entity.Property?.Name ?? "nekretnina";
            await _notificationService.CreateForUserAsync(
                entity.UserId,
                "Termin odobren",
                $"Vaš zahtjev za termin za nekretninu '{propertyName}' je odobren.",
                type: "appointment_status",
                referenceType: "appointment",
                referenceId: id
            );

            return result;
        }

        public async Task<AppointmentResponse> FinishAsync(int id)
        {
            var entity = await _context.Appointments
                .Include(a => a.Property)
                .FirstOrDefaultAsync(a => a.Id == id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            await CheckPropertyOwnershipAsync(id);

            var oldStatusId = entity.StatusId;
            var stateName = MapStatusToState(oldStatusId);
            var baseState = _baseState.GetState(stateName);
            var result = await baseState.ToFinishedAsync(id);
            AddHistory(id, oldStatusId, ReservationAppointmentStatus.Finished);
            await _context.SaveChangesAsync();

            var propertyName = entity.Property?.Name ?? "nekretnina";
            await _notificationService.CreateForUserAsync(
                entity.UserId,
                "Termin završen",
                $"Vaš termin za nekretninu '{propertyName}' je označen kao završen.",
                type: "appointment_status",
                referenceType: "appointment",
                referenceId: id
            );

            return result;
        }

        public async Task<AppointmentResponse> RejectAsync(int id, string? reason = null)
        {
            if (string.IsNullOrWhiteSpace(reason))
                throw new UserException("Razlog odbijanja je obavezan.");

            var entity = await _context.Appointments
                .Include(a => a.Property)
                .FirstOrDefaultAsync(a => a.Id == id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            await CheckPropertyOwnershipAsync(id);

            var oldStatusId = entity.StatusId;
            var stateName = MapStatusToState(oldStatusId);
            var baseState = _baseState.GetState(stateName);
            var result = await baseState.ToRejectedAsync(id);
            AddHistory(id, oldStatusId, ReservationAppointmentStatus.Rejected, reason);
            await _context.SaveChangesAsync();

            var propertyName = entity.Property?.Name ?? "nekretnina";
            await _notificationService.CreateForUserAsync(
                entity.UserId,
                "Termin odbijen",
                string.IsNullOrWhiteSpace(reason)
                    ? $"Vaš zahtjev za termin za nekretninu '{propertyName}' je odbijen."
                    : $"Vaš zahtjev za termin za nekretninu '{propertyName}' je odbijen. Razlog: {reason}",
                type: "appointment_status",
                referenceType: "appointment",
                referenceId: id
            );

            return result;
        }

        public async Task<AppointmentResponse> CancelAsync(int id, string? reason = null)
        {
            if (string.IsNullOrWhiteSpace(reason))
                throw new UserException("Razlog otkazivanja je obavezan.");

            var entity = await _context.Appointments
                .Include(a => a.Property)
                .FirstOrDefaultAsync(a => a.Id == id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            await CheckCancelAuthorizationAsync(id, entity.UserId);

            var oldStatusId = entity.StatusId;
            var stateName = MapStatusToState(oldStatusId);
            var baseState = _baseState.GetState(stateName);
            var result = await baseState.ToCancelledAsync(id);
            AddHistory(id, oldStatusId, ReservationAppointmentStatus.Cancelled, reason);
            await _context.SaveChangesAsync();

            var propertyName = entity.Property?.Name ?? "nekretnina";
            await _notificationService.CreateForUserAsync(
                entity.UserId,
                "Termin otkazan",
                string.IsNullOrWhiteSpace(reason)
                    ? $"Vaš termin za nekretninu '{propertyName}' je otkazan."
                    : $"Vaš termin za nekretninu '{propertyName}' je otkazan. Razlog: {reason}",
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
                .Where(a => a.StatusId == ReservationAppointmentStatus.Approved)
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
            if (entity.StatusId != ReservationAppointmentStatus.Rejected && entity.StatusId != ReservationAppointmentStatus.Finished)
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
                ReservationAppointmentStatus.Pending => nameof(PendingAppointmentState),
                ReservationAppointmentStatus.Approved => nameof(ApprovedAppointmentState),
                ReservationAppointmentStatus.Rejected => nameof(RejectedAppointmentState),
                ReservationAppointmentStatus.Cancelled => nameof(CancelledAppointmentState),
                ReservationAppointmentStatus.Finished => nameof(FinishedAppointmentState),
                _ => nameof(InitialAppointmentState)
            };
        }
    }
}
