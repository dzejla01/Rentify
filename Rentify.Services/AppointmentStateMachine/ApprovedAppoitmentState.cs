using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Rentify.Model;
using Rentify.Model.ResponseObjects;
using Rentify.Services.Database;
using Rentify.Services.Exceptions;

namespace Rentify.Services.AppointmentStateMachine
{
    public class ApprovedAppoitmentState : BaseAppointmentState
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public ApprovedAppoitmentState(
            IServiceProvider serviceProvider,
            IHttpContextAccessor httpContextAccessor,
            RentifyDbContext context,
            IMapper mapper) : base(serviceProvider, context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
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

        public override async Task<AppointmentResponse> ToCancelledAsync(int id)
        {
            var entity = await _context.Reservations
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            var user = _httpContextAccessor.HttpContext?.User;
            var isOwner = user?.IsInRole("Vlasnik") ?? false;
            var isUser = user?.IsInRole("Korisnik") ?? false;

            if (!isOwner && !isUser)
            {
                throw new UserException("Nemate pravo da otkažete ovu rezervaciju.");
            }

            // VLASNIK može otkazati kad god želi
            if (isOwner)
            {
                entity.Status = "Otkazano";

                await _context.SaveChangesAsync();
                return _mapper.Map<AppointmentResponse>(entity);
            }

            // KORISNIK pravila
            if (isUser)
            {
                if (entity.IsMonthly)
                {
                    var payments = await _context.Payments
                        .Where(p => p.ReservationId == id)
                        .ToListAsync();

                    if (payments.Any())
                    {
                        var hasUnpaidPayments = payments.Any(p =>
                            !p.IsPayed || p.PaymentStatus != "Paid");

                        if (hasUnpaidPayments)
                        {
                            throw new UserException(
                                "Najamnina se ne može otkazati dok sve poslane rate nisu plaćene."
                            );
                        }
                    }
                }
                else
                {
                    if (!entity.StartDateOfRenting.HasValue)
                        throw new UserException("Rezervacija nema definisan datum početka.");

                    var today = DateTime.UtcNow.Date;
                    var startDate = entity.StartDateOfRenting.Value.Date;
                    var daysUntilStart = (startDate - today).TotalDays;

                    if (daysUntilStart <= 3)
                    {
                        throw new UserException(
                            "Kratki boravak nije moguće otkazati 3 dana prije početka ili kasnije."
                        );
                    }
                }
            }

            entity.Status = "Otkazano";

            await _context.SaveChangesAsync();
            return _mapper.Map<AppointmentResponse>(entity);
        }

        public override List<string> AllowedActions(int id)
        {
            return new List<string>
            {
                nameof(ToFinishedAsync),
                nameof(ToCancelledAsync)
            };
        }
    }
}