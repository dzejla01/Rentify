using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? OwnersPropertyId { get; set; }
        public int? UserId { get; set; }
        public int? ReservationId { get; set; }
        public bool? IncludeReservation { get; set; }
    }
}
