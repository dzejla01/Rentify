using MapsterMapper;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;

namespace Rentify.Services.PaymentStateMachine
{
    public class FailedPaymentState : BasePaymentState
    {
        public FailedPaymentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<PaymentResponse> ToProcessingAsync(int id)
        {
            var entity = await GetEntity(id);

            entity.StatusId = PaymentStatus.Processing;
            entity.PaidAt = null;

            await _context.SaveChangesAsync();
            return _mapper.Map<PaymentResponse>(entity);
        }

        public override async Task<PaymentResponse> ToCancelledAsync(int id)
        {
            var entity = await GetEntity(id);

            entity.StatusId = PaymentStatus.Cancelled;
            entity.PaidAt = null;

            await _context.SaveChangesAsync();
            return _mapper.Map<PaymentResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>
            {
                nameof(ToProcessingAsync),
                nameof(ToCancelledAsync)
            };
        }
    }
}