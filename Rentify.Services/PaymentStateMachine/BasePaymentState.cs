using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;

namespace Rentify.Services.PaymentStateMachine
{
    public class BasePaymentState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly RentifyDbContext _context;
        protected readonly IMapper _mapper;

        public BasePaymentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        protected async Task<Payment> GetEntity(int id)
        {
            var entity = await _context.Payments
                .Include(x => x.Reservation)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                throw new UserException("Uplata nije pronađena.");

            return entity;
        }

        public virtual Task<PaymentResponse> ToPendingAsync(int id)
        {
            throw new UserException("Prelazak na status 'Na čekanju' nije dozvoljen.");
        }

        public virtual Task<PaymentResponse> ToProcessingAsync(int id)
        {
            throw new UserException("Prelazak na status 'Procesiranje' nije dozvoljen.");
        }

        public virtual Task<PaymentResponse> ToPaidAsync(int id)
        {
            throw new UserException("Prelazak na status 'Plaćeno' nije dozvoljen.");
        }

        public virtual Task<PaymentResponse> ToUnpaidAsync(int id)
        {
            throw new UserException("Prelazak na status 'Neplaćeno' nije dozvoljen.");
        }

        public virtual Task<PaymentResponse> ToCancelledAsync(int id)
        {
            throw new UserException("Prelazak na status 'Otkazano' nije dozvoljen.");
        }

        public virtual Task<PaymentResponse> ToFailedAsync(int id)
        {
            throw new UserException("Prelazak na status 'Neuspješno' nije dozvoljen.");
        }

        public virtual List<string> AllowedActions(int id)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public BasePaymentState GetState(string stateName)
        {
            return stateName switch
            {
                nameof(PendingPaymentState) => _serviceProvider.GetRequiredService<PendingPaymentState>(),
                nameof(ProcessingPaymentState) => _serviceProvider.GetRequiredService<ProcessingPaymentState>(),
                nameof(PaidPaymentState) => _serviceProvider.GetRequiredService<PaidPaymentState>(),
                nameof(UnpaidPaymentState) => _serviceProvider.GetRequiredService<UnpaidPaymentState>(),
                nameof(CancelledPaymentState) => _serviceProvider.GetRequiredService<CancelledPaymentState>(),
                nameof(FailedPaymentState) => _serviceProvider.GetRequiredService<FailedPaymentState>(),
                _ => throw new Exception($"State {stateName} nije definisan.")
            };
        }
    }
}