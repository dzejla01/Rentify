namespace Rentify.Model.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? PropertyId { get; set; }
        public bool? IsMonthly { get; set; }
        public int? StatusId { get; set; }
        public int? OwnerId { get; set; }

        public bool? IncludeUser { get; set; }
        public bool? IncludeProperty { get; set; }
    }
}
