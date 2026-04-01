using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class QuestionUpsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int PropertyId { get; set; }

        [Required]
        [MaxLength(1000)]
        public string Content { get; set; } = string.Empty;

        public bool IsAnswered { get; set; } = false;
    }
}