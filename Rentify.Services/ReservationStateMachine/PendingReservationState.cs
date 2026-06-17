using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;

namespace Rentify.Services.ReservationStateMachine
{
    public class PendingReservationState : BaseReservationState
    {
        public PendingReservationState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<ReservationResponse> UpdateAsync(int id, ReservationUpsertRequest request)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();
            return _mapper.Map<ReservationResponse>(entity);
        }

        public override async Task<ReservationResponse> ToApprovedAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            if (!entity.StartDateOfRenting.HasValue || !entity.EndDateOfRenting.HasValue)
                throw new UserException("Rezervacija nema definisan period.");

            var start = entity.StartDateOfRenting.Value;
            var end = entity.EndDateOfRenting.Value;

            if (entity.IsMonthly)
            {
                var hasApprovedMonthlyConflict = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.Id != entity.Id)
                    .Where(r => r.PropertyId == entity.PropertyId)
                    .Where(r => r.IsMonthly == true)
                    .Where(r => r.StatusId == ReservationAppointmentStatus.Approved)
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start < r.EndDateOfRenting!.Value &&
                        end > r.StartDateOfRenting!.Value
                    );

                if (hasApprovedMonthlyConflict)
                {
                    throw new UserException(
                        "Najamnina se ne može odobriti jer već postoji odobrena najamnina za ovu nekretninu u odabranom periodu."
                    );
                }

                var hasApprovedShortStayConflict = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.Id != entity.Id)
                    .Where(r => r.PropertyId == entity.PropertyId)
                    .Where(r => r.IsMonthly == false)
                    .Where(r => r.StatusId == ReservationAppointmentStatus.Approved)
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start < r.EndDateOfRenting!.Value &&
                        end > r.StartDateOfRenting!.Value
                    );

                if (hasApprovedShortStayConflict)
                {
                    throw new UserException(
                        "Najamnina se ne može odobriti jer već postoji odobren kratki boravak za ovu nekretninu u tom periodu."
                    );
                }
            }
            else
            {
                var hasApprovedShortStayConflict = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.Id != entity.Id)
                    .Where(r => r.PropertyId == entity.PropertyId)
                    .Where(r => r.IsMonthly == false)
                    .Where(r => r.StatusId == ReservationAppointmentStatus.Approved)
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start < r.EndDateOfRenting!.Value &&
                        end > r.StartDateOfRenting!.Value
                    );

                if (hasApprovedShortStayConflict)
                {
                    throw new UserException(
                        "Kratki boravak se ne može odobriti jer već postoji odobren kratki boravak za ovu nekretninu u tom periodu."
                    );
                }

                var hasApprovedMonthlyConflict = await _context.Reservations
                    .AsNoTracking()
                    .Where(r => r.Id != entity.Id)
                    .Where(r => r.PropertyId == entity.PropertyId)
                    .Where(r => r.IsMonthly == true)
                    .Where(r => r.StatusId == ReservationAppointmentStatus.Approved)
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start < r.EndDateOfRenting!.Value &&
                        end > r.StartDateOfRenting!.Value
                    );

                if (hasApprovedMonthlyConflict)
                {
                    throw new UserException(
                        "Kratki boravak se ne može odobriti jer već postoji odobrena najamnina za ovu nekretninu u tom periodu."
                    );
                }
            }

            entity.StatusId = ReservationAppointmentStatus.Approved;

            await _context.SaveChangesAsync();
            return _mapper.Map<ReservationResponse>(entity);
        }

        public override async Task<ReservationResponse> ToRejectedAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            entity.StatusId = ReservationAppointmentStatus.Rejected;

            await _context.SaveChangesAsync();
            return _mapper.Map<ReservationResponse>(entity);
        }

        public override async Task<ReservationResponse> ToCancelledAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            entity.StatusId = ReservationAppointmentStatus.Cancelled;

            await _context.SaveChangesAsync();
            return _mapper.Map<ReservationResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>
            {
                nameof(UpdateAsync),
                nameof(ToApprovedAsync),
                nameof(ToRejectedAsync),
                nameof(ToCancelledAsync)
            };
        }
    }
}