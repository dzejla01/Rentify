using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using Rentify.Model;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;

namespace Rentify.Services.AppointmentStateMachine
{
    public class BaseAppointmentState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly RentifyDbContext _context;
        protected readonly IMapper _mapper;

        public BaseAppointmentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<AppointmentResponse> CreateAsync(AppointmentUpsertRequest request)
        {
            throw new UserException("Akcija nije dozvoljena.");
        }

        public virtual async Task<AppointmentResponse> UpdateAsync(int id, AppointmentUpsertRequest request)
        {
            throw new UserException("Akcija nije dozvoljena.");
        }

        public virtual async Task<AppointmentResponse> ToApprovedAsync(int id)
        {
            throw new UserException("Prelazak na status 'Odobreno' nije dozvoljen.");
        }

        public virtual async Task<AppointmentResponse> ToFinishedAsync(int id)
        {
            throw new UserException("Prelazak na status 'Završeno' nije dozvoljen.");
        }

        public virtual async Task<AppointmentResponse> ToRejectedAsync(int id)
        {
            throw new UserException("Prelazak na status 'Odbijeno' nije dozvoljen.");
        }

        public virtual async Task<AppointmentResponse> ToCancelledAsync(int id)
        {
            throw new UserException("Prelazak na status 'Otkazano' nije dozvoljen.");
        }

        public virtual List<string> AllowedActions(int id)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public BaseAppointmentState GetState(string stateName)
        {
            return stateName switch
            {
                nameof(InitialAppointmentState) => _serviceProvider.GetRequiredService<InitialAppointmentState>(),
                nameof(PendingAppointmentState) => _serviceProvider.GetRequiredService<PendingAppointmentState>(),
                nameof(ApprovedAppoitmentState) => _serviceProvider.GetRequiredService<ApprovedAppoitmentState>(),
                nameof(FinishedAppointmentState) => _serviceProvider.GetRequiredService<FinishedAppointmentState>(),
                nameof(RejectedAppointmentState) => _serviceProvider.GetRequiredService<RejectedAppointmentState>(),
                nameof(CancelledAppointmentState) => _serviceProvider.GetRequiredService<CancelledAppointmentState>(),
                _ => throw new Exception($"State {stateName} nije definisan.")
            };
        }
    }
}