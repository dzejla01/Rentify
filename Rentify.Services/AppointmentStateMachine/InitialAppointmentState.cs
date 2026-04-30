using MapsterMapper;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;

namespace Rentify.Services.AppointmentStateMachine
{
    public class InitialAppointmentState : BaseAppointmentState
    {
        public InitialAppointmentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper
        ) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<AppointmentResponse> CreateAsync(AppointmentUpsertRequest request)
        {
            var entity = _mapper.Map<Appointment>(request);

            if (string.IsNullOrWhiteSpace(entity.Status))
                entity.Status = "Na čekanju";

            _context.Appointments.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>
            {
                nameof(CreateAsync)
            };
        }
    }
}