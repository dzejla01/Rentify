using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class AnswerUpsertRequest
    {
        [Required]
        public int QuestionId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        [MaxLength(1000)]
        public string Content { get; set; } = string.Empty;
    }
}