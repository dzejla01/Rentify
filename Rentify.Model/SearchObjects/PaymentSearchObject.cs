namespace Rentify.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public int? ReservationId { get; set; }
        public int? UserId { get; set; }
        public int? PropertyId { get; set; }
        public bool? IsPayed { get; set; }
        public int? MonthNumber { get; set; }
        public int? YearNumber { get; set; }
        public int? ReservationStatusId { get; set; }
        public int? StatusId { get; set; }

        public bool? IncludeUser { get; set; }
        public bool? IncludeProperty { get; set; }
    }
}
