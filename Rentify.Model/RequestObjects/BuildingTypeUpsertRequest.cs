using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class BuildingTypeUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = null!;
    }
}
