using System;
using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? PropertyId { get; set; }
        public bool? IsPayed { get; set; }
        public int? MonthNumber { get; set;}
        public int? YearNumber { get; set; }
    }
}
