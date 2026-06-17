namespace Rentify.Model.ResponseObjects
{
    public class BestOwnerByYearResponse
    {
        public int Year { get; set; }
        public int OwnerId { get; set; }
        public string OwnerName { get; set; } = string.Empty;
        public int TotalReservations { get; set; }
        public decimal TotalIncome { get; set; }
    }
}