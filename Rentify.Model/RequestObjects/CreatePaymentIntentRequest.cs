using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class CreatePaymentIntentRequest
    {
        [Required]
        public int PaymentId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public int PropertyId { get; set; }


        [Required]
        public bool IsMonthly { get; set; }

        public int MonthNumber { get; set; }

        public int YearNumber { get; set; }
    }
}