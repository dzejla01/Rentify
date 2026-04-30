using MapsterMapper;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;

namespace Rentify.Services.AppointmentStateMachine
{
    public class ApprovedAppointmentState : BaseAppointmentState
    {
        public ApprovedAppointmentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper
        ) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<AppointmentResponse> ToFinishedAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            entity.Status = "Završeno";

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override async Task<AppointmentResponse> ToCancelledAsync(int id)
        {
            var entity = await _context.Appointments.FindAsync(id);
            if (entity == null)
                throw new UserException("Termin nije pronađen.");

            entity.Status = "Otkazano";

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>
            {
                nameof(ToFinishedAsync),
                nameof(ToCancelledAsync)
            };
        }
    }
}