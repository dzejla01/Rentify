using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rentify.Services.Database
{
    public class Answer
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [ForeignKey(nameof(QuestionId))]
        public int QuestionId { get; set; }
        public Question Question { get; set; }

        [Required]
        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; }
        public User User { get; set; }

        [Required]
        [MaxLength(1000)]
        public string Content { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}