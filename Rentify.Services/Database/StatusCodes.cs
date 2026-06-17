namespace Rentify.Services.Database
{
    /// <summary>
    /// Stabilan kod-sloj za StatusId vrijednosti rezervacija i termina (1:1 sa SeedData/Status tabelom).
    /// Business logika (state machine, servisi) treba uvijek koristiti ove konstante umjesto "magic" brojeva.
    /// </summary>
    public static class ReservationAppointmentStatus
    {
        public const int Pending = 1;
        public const int Approved = 2;
        public const int Finished = 3;
        public const int Rejected = 4;
        public const int Cancelled = 5;
    }

    /// <summary>
    /// Stabilan kod-sloj za StatusId vrijednosti uplata (1:1 sa SeedData/Status tabelom).
    /// </summary>
    public static class PaymentStatus
    {
        public const int Pending = 1;
        public const int Cancelled = 5;
        public const int Processing = 6;
        public const int Paid = 7;
        public const int Unpaid = 8;
        public const int Failed = 9;
    }
}
