using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Rentify.Model;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;

namespace Rentify.Services.AppointmentStateMachine
{
    public class PendingAppointmentState : BaseAppointmentState
    {
        public PendingAppointmentState(
            IServiceProvider serviceProvider,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<AppointmentResponse> UpdateAsync(int id, AppointmentUpsertRequest request)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override async Task<AppointmentResponse> ToApprovedAsync(int id)
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
                    .Where(r => r.Status == "Odobreno")
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start <= r.EndDateOfRenting!.Value &&
                        end >= r.StartDateOfRenting!.Value
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
                    .Where(r => r.Status == "Odobreno")
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
                    .Where(r => r.Status == "Odobreno")
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
                    .Where(r => r.Status == "Odobreno")
                    .Where(r => r.StartDateOfRenting != null && r.EndDateOfRenting != null)
                    .AnyAsync(r =>
                        start <= r.EndDateOfRenting!.Value &&
                        end >= r.StartDateOfRenting!.Value
                    );

                if (hasApprovedMonthlyConflict)
                {
                    throw new UserException(
                        "Kratki boravak se ne može odobriti jer već postoji odobrena najamnina za ovu nekretninu u tom periodu."
                    );
                }
            }

            entity.Status = "Odobreno";

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override async Task<AppointmentResponse> ToFinishedAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            entity.Status = "Završeno";

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override async Task<AppointmentResponse> ToRejectedAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            entity.Status = "Odbijeno";

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override async Task<AppointmentResponse> ToCancelledAsync(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            entity.Status = "Otkazano";

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>
            {
                nameof(UpdateAsync),
                nameof(ToApprovedAsync),
                nameof(ToFinishedAsync),
                nameof(ToRejectedAsync),
                nameof(ToCancelledAsync)
            };
        }
    }
}