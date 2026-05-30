using System;

namespace Rentify.Model.ResponseObjects
{
    public class ExpenseResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public UserResponse? User { get; set; }
        public int? PropertyId { get; set; }
        public PropertyResponse? Property { get; set; }
        public string Description { get; set; } = null!;
        public decimal Amount { get; set; }
        public DateTime Date { get; set; }
        public string Category { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
    }
}
