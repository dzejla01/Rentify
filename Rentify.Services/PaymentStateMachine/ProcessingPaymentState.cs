using MapsterMapper;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;

namespace Rentify.Services.PaymentStateMachine
{
    public class ProcessingPaymentState : BasePaymentState
    {
        public ProcessingPaymentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<PaymentResponse> ToPaidAsync(int id)
        {
            var entity = await GetEntity(id);

            entity.StatusId = PaymentStatus.Paid;
            entity.PaidAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return _mapper.Map<PaymentResponse>(entity);
        }

        public override async Task<PaymentResponse> ToFailedAsync(int id)
        {
            var entity = await GetEntity(id);

            entity.StatusId = PaymentStatus.Failed;
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
                nameof(ToPaidAsync),
                nameof(ToFailedAsync),
                nameof(ToCancelledAsync)
            };
        }
    }
}