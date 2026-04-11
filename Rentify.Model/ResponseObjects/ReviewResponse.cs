namespace Rentify.Model.ResponseObjects
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int ReservationId { get; set; }
        public ReservationResponse? Reservation { get; set;}
        public string Comment { get; set; } = null!;
        public int StarRate { get; set; }
    }
}
