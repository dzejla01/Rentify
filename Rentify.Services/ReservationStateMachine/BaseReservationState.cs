using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using Rentify.Model;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.AppointmentStateMachine;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;
using Rentify.Services.ReservationStateMachine;

namespace Rentify.Services.ReservationStateMachine
{
    public class BaseReservationState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly RentifyDbContext _context;
        protected readonly IMapper _mapper;

        public BaseReservationState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<ReservationResponse> CreateAsync(ReservationUpsertRequest request)
        {
            throw new UserException("Akcija nije dozvoljena.");
        }

        public virtual async Task<ReservationResponse> UpdateAsync(int id, ReservationUpsertRequest request)
        {
            throw new UserException("Akcija nije dozvoljena.");
        }

        public virtual async Task<ReservationResponse> ToApprovedAsync(int id)
        {
            throw new UserException("Prelazak na status 'Odobreno' nije dozvoljen.");
        }

        public virtual async Task<ReservationResponse> ToFinishedAsync(int id)
        {
            throw new UserException("Prelazak na status 'Završeno' nije dozvoljen.");
        }

        public virtual async Task<ReservationResponse> ToRejectedAsync(int id)
        {
            throw new UserException("Prelazak na status 'Odbijeno' nije dozvoljen.");
        }

        public virtual async Task<ReservationResponse> ToCancelledAsync(int id)
        {
            throw new UserException("Prelazak na status 'Otkazano' nije dozvoljen.");
        }

        public virtual List<string> AllowedActions(int id)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public BaseReservationState GetState(string stateName)
        {
            return stateName switch
            {
                nameof(InitialReservationState) => _serviceProvider.GetRequiredService<InitialReservationState>(),
                nameof(PendingReservationState) => _serviceProvider.GetRequiredService<PendingReservationState>(),
                nameof(ApprovedReservationState) => _serviceProvider.GetRequiredService<ApprovedReservationState>(),
                nameof(FinishedReservationState) => _serviceProvider.GetRequiredService<FinishedReservationState>(),
                nameof(RejectedReservationState) => _serviceProvider.GetRequiredService<RejectedReservationState>(),
                nameof(CancelledReservationState) => _serviceProvider.GetRequiredService<CancelledReservationState>(),
                _ => throw new Exception($"State {stateName} nije definisan.")
            };
        }
    }
}