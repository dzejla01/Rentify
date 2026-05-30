using MapsterMapper;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;

namespace Rentify.Services.ReservationStateMachine
{
    public class InitialReservationState : BaseReservationState
    {
        public InitialReservationState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ReservationResponse> CreateAsync(ReservationUpsertRequest request)
        {
            var entity = new Database.Reservation();
            _mapper.Map(request, entity);

            entity.StatusId = 1;
            entity.CreatedAt = DateTime.UtcNow;

            _context.Reservations.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<ReservationResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string> { nameof(CreateAsync) };
        }
    }
}