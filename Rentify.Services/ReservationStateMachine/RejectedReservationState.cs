using MapsterMapper;
using Rentify.Services.Database;

namespace Rentify.Services.ReservationStateMachine
{
    public class RejectedReservationState : BaseReservationState
    {
        public RejectedReservationState(
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