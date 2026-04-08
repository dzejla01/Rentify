using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rentify.Services.Database
{
    public class ReservationHistory
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey(nameof(ReservationId))]
        public int ReservationId { get; set; }
        public Reservation Reservation { get; set; }

        [Required]
        [MaxLength(100)]
        public string Status { get; set; } = string.Empty; 

        [MaxLength(500)]
        public string? Note { get; set; }

        public DateTime ChangedAt { get; set; } = DateTime.Now;
    }
}