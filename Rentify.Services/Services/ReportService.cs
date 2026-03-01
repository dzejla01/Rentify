using Microsoft.EntityFrameworkCore;
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

            // samo plaćeni payments + samo ownerove nekretnine
            var baseQ = _context.Payments
                .AsNoTracking()
                .Include(p => p.Property)
                .Where(p => p.IsPayed == true)
                .Where(p => p.Property != null && p.Property.UserId == search.OwnerId);

            // trend: po Year/Month iz paymenta
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

            // desno: po nekretnini za odabrani mjesec
            var byProperty = new List<PropertyIncomeDto>();

            if (search.Year.HasValue && search.Month.HasValue)
            {
                var y = search.Year.Value;
                var m = search.Month.Value;

                byProperty = await baseQ
                    .Where(p => p.YearNumber == y && p.MonthNumber == m)
                    .GroupBy(p => new { p.PropertyId, p.Property!.Name })
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
    }
}