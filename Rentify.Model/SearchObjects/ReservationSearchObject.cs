using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? PropertyId { get; set; }
        public bool? IsMonthly { get; set; }
        public bool? IsApproved { get; set; }
        public int? OwnerId {get; set;}

        // Include
        public bool? IncludeUser {get; set;}
        public bool? IncludeProperty {get; set;}
    }
}
