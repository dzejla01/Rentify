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

        [ForeignKey(nameof(ReservationId))]
        public int ReservationId { get; set; }
        public Reservation? Reservation { get; set; }
        public string Name {get; set;}
        public string Comment {get; set;}
        public decimal Price { get; set; }
        public int MonthNumber { get; set; }
        public int YearNumber { get; set; }
        public DateTime? DateToPay { get; set; }
        public DateTime? WarningDateToPay { get; set; }
        public DateTime? SecondWarningDate { get; set; }
        public string? StripePaymentIntentId { get; set; }
        public DateTime? PaidAt { get; set; }
        public string PaymentStatus { get; set; } = "Na čekanju"; 
    }
}
