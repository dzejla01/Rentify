using System.Collections.Generic;

namespace Rentify.Model.ResponseObjects
{
    public class PropertyResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Name { get; set; } = null!;
        public string Location { get; set; } = null!;
        public string City { get; set; } = null!;
        public double PricePerDay { get; set; }
        public double PricePerMonth { get; set; }
        public List<string>? Tags { get; set; }
        public string? NumberOfsquares { get; set; }
        public string? Details { get; set; }
        public bool IsAvailable { get; set; }
        public bool IsActiveOnApp { get; set; }
    }
}
