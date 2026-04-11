using MapsterMapper;
using Rentify.Services.Database;

namespace Rentify.Services.AppointmentStateMachine
{
    public class CancelledAppointmentState : BaseAppointmentState
    {
        public CancelledAppointmentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>();
        }
    }
}