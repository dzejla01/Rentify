namespace Rentify.Model.SearchObjects
{

    public class IncomeReportSearchObject
    {
        public int OwnerId { get; set; }
        public int? Year { get; set; }   
        public int? Month { get; set; }
        public int MonthsBack { get; set; } = 6; 
    }
}
