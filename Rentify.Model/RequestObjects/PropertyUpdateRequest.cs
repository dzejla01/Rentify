using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class PropertyUpdateRequest
    {
        [Required]
        public string Name { get; set; } = null!;

        [Required]
        public string City { get; set; }

        [Required]
        public string Location { get; set; } = null!;

        [Range(0, double.MaxValue)]
        public double PricePerDay { get; set; }

        [Range(0, double.MaxValue)]
        public double PricePerMonth { get; set; }

        public List<string>? Tags { get; set; }

        public string? NumberOfsquares { get; set; }

        [Required]
        public string? Details { get; set; }

        public bool IsAvailable { get; set; } = true;
    }
}
