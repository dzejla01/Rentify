using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rentify.Services.Database
{
    public class Favorite
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; }
        public User User { get; set; }

        [Required]
        [ForeignKey(nameof(PropertyId))]
        public int PropertyId { get; set; }
        public Property Property { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}