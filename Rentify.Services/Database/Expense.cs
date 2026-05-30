using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rentify.Services.Database
{
    public class Expense
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; }
        public User User { get; set; }

        public int? PropertyId { get; set; }
        public Property? Property { get; set; }

        public string Description { get; set; }
        public decimal Amount { get; set; }
        public DateTime Date { get; set; }
        public string Category { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
