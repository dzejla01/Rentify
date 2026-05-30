using System;

namespace Rentify.Model.SearchObjects
{
    public class ExpenseSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? PropertyId { get; set; }
        public string? Category { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
        public bool? IncludeProperty { get; set; }
        public bool? IncludeUser { get; set; }
    }
}
