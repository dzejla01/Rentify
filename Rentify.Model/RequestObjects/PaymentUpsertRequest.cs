using System;
using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class PaymentUpsertRequest
    {
        

        [Required]
        public int ReservationId { get; set; }

        public decimal Price { get; set; }

        public string Name {get; set;}

        public string? Comment {get; set;}

        public int MonthNumber { get; set; }
        public int YearNumber { get; set; } 

        public DateTime? DateToPay { get; set; }
        public DateTime? WarningDateToPay { get; set; }
        public DateTime? SecondWarningDate { get; set; }
        public string PaymentStatus { get; set; } = "Na čekanju";
    }
}
