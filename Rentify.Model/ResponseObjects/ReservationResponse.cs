using System;

namespace Rentify.Model.ResponseObjects
{
    public class ReservationResponse
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public UserResponse? User {get; set;}
        public int PropertyId { get; set; }
        public PropertyResponse? Property {get; set;}

        public bool IsMonthly { get; set; }

        public bool? IsApproved { get; set; }

        public DateTime? CreatedAt {get; set;}

        public DateTime? StartDateOfRenting {get; set;}
        public DateTime? EndDateOfRenting {get; set;}
    }
}
