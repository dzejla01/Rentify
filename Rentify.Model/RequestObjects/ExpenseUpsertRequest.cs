using System;

namespace Rentify.Model.RequestObjects
{
    public class ExpenseUpsertRequest
    {
        public int UserId { get; set; }
        public int? PropertyId { get; set; }
        public string Description { get; set; } = null!;
        public decimal Amount { get; set; }
        public DateTime Date { get; set; }
        public string Category { get; set; } = null!;
    }
}
