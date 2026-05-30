using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rentify.Services.Database
{
    public class Appointment
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; }
        public User? User { get; set; }

        [ForeignKey(nameof(PropertyId))]
        public int PropertyId { get; set; }
        public Property? Property { get; set; }

        public DateTime? DateAppointment { get; set; }

        [ForeignKey(nameof(StatusId))]
        public int StatusId { get; set; } = 1;
        public Status? Status { get; set; }
    }
}
