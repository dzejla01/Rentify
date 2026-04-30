using MapsterMapper;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;

namespace Rentify.Services.PaymentStateMachine
{
    public class PendingPaymentState : BasePaymentState
    {
        public PendingPaymentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<PaymentResponse> ToProcessingAsync(int id)
        {
            var entity = await GetEntity(id);

            entity.PaymentStatus = "Procesiranje";
            entity.PaidAt = null;

            await _context.SaveChangesAsync();
            return _mapper.Map<PaymentResponse>(entity);
        }

        public override async Task<PaymentResponse> ToPaidAsync(int id)
        {
            var entity = await GetEntity(id);

            entity.PaymentStatus = "Plaćeno";
            entity.PaidAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return _mapper.Map<PaymentResponse>(entity);
        }

        public override async Task<PaymentResponse> ToUnpaidAsync(int id)
        {
            var entity = await GetEntity(id);

            entity.PaymentStatus = "Neplaćeno";
            entity.PaidAt = null;

            await _context.SaveChangesAsync();
            return _mapper.Map<PaymentResponse>(entity);
        }

        public override async Task<PaymentResponse> ToCancelledAsync(int id)
        {
            var entity = await GetEntity(id);

            entity.PaymentStatus = "Otkazano";
            entity.PaidAt = null;

            await _context.SaveChangesAsync();
            return _mapper.Map<PaymentResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>
            {
                nameof(ToProcessingAsync),
                nameof(ToPaidAsync),
                nameof(ToUnpaidAsync),
                nameof(ToCancelledAsync)
            };
        }
    }
}