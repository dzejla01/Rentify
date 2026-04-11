using MapsterMapper;
using Rentify.Services.Database;

namespace Rentify.Services.ReservationStateMachine
{
    public class FinishedReservationState : BaseReservationState
    {
        public FinishedReservationState(
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