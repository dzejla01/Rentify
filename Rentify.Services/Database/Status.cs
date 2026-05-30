using System.ComponentModel.DataAnnotations;

namespace Rentify.Services.Database
{
    public class Status
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = null!;
    }
}
