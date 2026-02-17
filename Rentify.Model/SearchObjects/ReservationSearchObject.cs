using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? PropertyId { get; set; }
        public bool? IsMonthly { get; set; }
        public bool? IsApproved { get; set; }

        // Include
        public bool? IsUser {get; set;}
        public bool? IsProperty {get; set;}
    }
}
