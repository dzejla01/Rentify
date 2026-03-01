
using Rentify.Model.ResponseObjects;
using Rentify.Model.SearchObjects;

namespace Rentify.Services.Interfaces
{
    public interface IReportService
    {
        Task<IncomeReportDto> GetIncomeReportAsync(IncomeReportSearchObject search);
    }
}