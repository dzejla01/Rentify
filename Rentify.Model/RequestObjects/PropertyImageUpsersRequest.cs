using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class PropertyImageUpsertRequest
    {
        [Required]
        public int PropertyId { get; set; }

        [Required]
        public string PropertyImg { get; set; } = string.Empty;

        public bool IsMain { get; set; }
    }
}
