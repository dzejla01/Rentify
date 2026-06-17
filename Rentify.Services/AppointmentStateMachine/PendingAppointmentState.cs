using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;

namespace Rentify.Services.AppointmentStateMachine
{
    public class PendingAppointmentState : BaseAppointmentState
    {
        public PendingAppointmentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper
        ) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<AppointmentResponse> UpdateAsync(int id, AppointmentUpsertRequest request)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override async Task<AppointmentResponse> ToApprovedAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            if (!entity.DateAppointment.HasValue)
                throw new UserException("Termin nema definisan datum.");

            var hasConflict = await _context.Appointments
                .AsNoTracking()
                .Where(x => x.Id != entity.Id)
                .Where(x => x.PropertyId == entity.PropertyId)
                .Where(x => x.StatusId == ReservationAppointmentStatus.Approved)
                .Where(x => x.DateAppointment != null)
                .AnyAsync(x => x.DateAppointment == entity.DateAppointment);

            if (hasConflict)
            {
                throw new UserException(
                    "Termin se ne može odobriti jer već postoji odobren termin za ovu nekretninu u tom terminu."
                );
            }

            entity.StatusId = ReservationAppointmentStatus.Approved;

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override async Task<AppointmentResponse> ToRejectedAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            entity.StatusId = ReservationAppointmentStatus.Rejected;

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override async Task<AppointmentResponse> ToCancelledAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            entity.StatusId = ReservationAppointmentStatus.Cancelled;

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>
            {
                nameof(UpdateAsync),
                nameof(ToApprovedAsync),
                nameof(ToRejectedAsync),
                nameof(ToCancelledAsync)
            };
        }
    }
}