using System;

namespace Rentify.Model.ResponseObjects
{
    public class PaymentResponse
    {
        public int Id { get; set; }

        public int ReservationId { get; set; }
        public ReservationResponse? Reservation { get; set; }
        public string Name { get; set; }
        public string Comment { get; set; }
        public decimal Price { get; set; }
        public int MonthNumber { get; set; }
        public int YearNumber { get; set; }
        public DateTime? DateToPay { get; set; }
        public DateTime? WarningDateToPay { get; set; }
        public DateTime? SecondWarningDate { get; set; }

        public int StatusId { get; set; }
        public StatusResponse? Status { get; set; }
    }
}
