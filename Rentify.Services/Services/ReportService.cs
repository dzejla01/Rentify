using Microsoft.EntityFrameworkCore;
using Rentify.Model.RequestObjects;
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;
using Rentify.Services.Interfaces;


namespace Rentify.Services.Services
{
    public class ReportService : IReportService
    {
        private readonly RentifyDbContext _context;

        public ReportService(RentifyDbContext context)
        {
            _context = context;
        }

        public async Task<IncomeReportDto> GetIncomeReportAsync(IncomeReportSearchObject search)
        {
            if (search == null)
                throw new ArgumentNullException(nameof(search));

            if (search.OwnerId <= 0)
                throw new ArgumentException("OwnerId je obavezan.", nameof(search.OwnerId));

            var baseQ = _context.Payments
                .AsNoTracking()
                .Include(p => p.Reservation)
                  .ThenInclude(p => p.Property)
                .Where(p => p.StatusId == 7)
                .Where(p => p.Reservation.Property != null && p.Reservation.Property.UserId == search.OwnerId);

            var monthly = await baseQ
                .GroupBy(p => new { p.YearNumber, p.MonthNumber })
                .Select(g => new MonthlyIncomeDto
                {
                    Year = g.Key.YearNumber,
                    Month = g.Key.MonthNumber,
                    Total = g.Sum(x => (decimal)x.Price)
                })
                .OrderBy(x => x.Year)
                .ThenBy(x => x.Month)
                .ToListAsync();

            var byProperty = new List<PropertyIncomeDto>();

            if (search.Year.HasValue && search.Month.HasValue)
            {
                var y = search.Year.Value;
                var m = search.Month.Value;

                byProperty = await baseQ
                    .Where(p => p.YearNumber == y && p.MonthNumber == m)
                    .GroupBy(p => new { p.Reservation.PropertyId, p.Reservation.Property!.Name })
                    .Select(g => new PropertyIncomeDto
                    {
                        PropertyId = g.Key.PropertyId,
                        PropertyName = g.Key.Name,
                        Total = g.Sum(x => (decimal)x.Price)
                    })
                    .OrderByDescending(x => x.Total)
                    .ToListAsync();
            }

            return new IncomeReportDto
            {
                Monthly = monthly,
                ByProperty = byProperty
            };
        }

        public async Task<BestOwnerByYearResponse?> GetBestOwnerByYearAsync(BestOwnerByYearRequest request)
        {
            if (request == null)
                throw new ArgumentNullException(nameof(request));

            if (request.Year < 2000 || request.Year > DateTime.UtcNow.Year + 1)
                throw new ArgumentException("Godina nije validna.");

            var reservations = await _context.Reservations
                .AsNoTracking()
                .Include(r => r.Property)
                    .ThenInclude(p => p.User)
                .Where(r =>
                    r.Property != null &&
                    r.Property.User != null &&
                    r.CreatedAt.Year == request.Year &&
                    (r.StatusId == 3 || r.StatusId == 2))
                .ToListAsync();

            var bestOwner = reservations
                .GroupBy(r => new
                {
                    OwnerId = r.Property!.UserId,
                    OwnerName = $"{r.Property!.User.FirstName} {r.Property!.User.LastName}"
                })
                .Select(g => new BestOwnerByYearResponse
                {
                    Year = request.Year,
                    OwnerId = g.Key.OwnerId,
                    OwnerName = g.Key.OwnerName,
                    TotalReservations = g.Count()
                })
                .OrderByDescending(x => x.TotalReservations)
                .ThenBy(x => x.OwnerName)
                .FirstOrDefault();

            return bestOwner;
        }
    }
}