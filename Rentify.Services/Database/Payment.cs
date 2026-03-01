using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rentify.Services.Database
{
    public class Payment
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; }
        public User? User { get; set; }

        [ForeignKey(nameof(PropertyId))]
        public int PropertyId { get; set; }
        public Property? Property { get; set; }
        public string Name {get; set;}
        public string Comment {get; set;}
        public double Price { get; set; }
        public bool IsPayed { get; set; }
        public int MonthNumber { get; set; }
        public int YearNumber { get; set; }
        public DateTime? DateToPay { get; set; }
        public DateTime? WarningDateToPay { get; set; }
        public string? StripePaymentIntentId { get; set; }
        public DateTime? PaidAt { get; set; }
        public string PaymentStatus { get; set; } = "Pending"; 
    }
}
