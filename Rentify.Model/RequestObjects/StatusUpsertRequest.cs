using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class StatusUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = null!;
    }
}
