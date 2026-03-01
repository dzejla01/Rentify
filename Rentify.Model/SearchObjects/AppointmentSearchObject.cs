using System;
using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class AppointmentSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? OwnerId { get; set; }
        public int? PropertyId { get; set; }
        public bool? IsApproved { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
        public bool? IncludeUser {get; set;}
        public bool? IncludeProperty {get; set;}
    }
}
