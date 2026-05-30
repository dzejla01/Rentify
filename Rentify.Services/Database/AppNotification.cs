using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rentify.Services.Database
{
    public class AppNotification
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; }
        public User? User { get; set; }

        [Required]
        [MaxLength(120)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MaxLength(500)]
        public string Message { get; set; } = string.Empty;

        [MaxLength(80)]
        public string? Type { get; set; }

        [MaxLength(80)]
        public string? ReferenceType { get; set; }

        public int? ReferenceId { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? ReadAt { get; set; }
    }
}
