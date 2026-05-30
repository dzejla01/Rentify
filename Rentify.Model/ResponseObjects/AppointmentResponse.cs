using System;

namespace Rentify.Model.ResponseObjects
{
    public class AppointmentResponse
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public UserResponse? User { get; set; }
        public int PropertyId { get; set; }
        public PropertyResponse? Property { get; set; }

        public DateTime? DateAppointment { get; set; }

        public int StatusId { get; set; }
        public StatusResponse? Status { get; set; }
    }
}
