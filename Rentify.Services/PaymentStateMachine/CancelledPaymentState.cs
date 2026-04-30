using MapsterMapper;
using Rentify.Services.Database;

namespace Rentify.Services.PaymentStateMachine
{
    public class CancelledPaymentState : BasePaymentState
    {
        public CancelledPaymentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override List<string> AllowedActions(int id) => new();
    }
}