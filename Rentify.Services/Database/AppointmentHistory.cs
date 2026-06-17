using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rentify.Services.Database
{
    public class AppointmentHistory
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey(nameof(AppointmentId))]
        public int AppointmentId { get; set; }
        public Appointment Appointment { get; set; }

        [ForeignKey(nameof(StatusId))]
        public int StatusId { get; set; }
        public Status? Status { get; set; }

        public int? OldStatusId { get; set; }
        public int? NewStatusId { get; set; }
        public int? ChangedByUserId { get; set; }

        [MaxLength(500)]
        public string? Reason { get; set; }

        [MaxLength(500)]
        public string? Note { get; set; }

        public DateTime ChangedAt { get; set; } = DateTime.UtcNow;
    }
}
