using System.Collections.Generic;

namespace Rentify.Model.ResponseObjects
{
    public class IncomeReportDto
    {
        public List<MonthlyIncomeDto> Monthly { get; set; }
        public List<PropertyIncomeDto> ByProperty { get; set; }
    }

}