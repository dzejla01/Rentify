using System;
using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class AppointmentUpsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int PropertyId { get; set; }

        public DateTime? DateAppointment { get; set; }

        public string Status { get; set; } = "Na čekanju";
    }
}
