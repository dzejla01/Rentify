using System.Collections.Generic;

namespace Rentify.Model.ResponseObjects
{
    public class PropertyResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public UserResponse? User { get; set; }
        public string Name { get; set; } = null!;
        public string Location { get; set; } = null!;
        public int CityId { get; set; }
        public CityResponse? City { get; set; }
        public int BuildingTypeId { get; set; }
        public BuildingTypeResponse? BuildingType { get; set; }
        public decimal PricePerDay { get; set; }
        public decimal PricePerMonth { get; set; }
        public List<string>? Tags { get; set; }
        public double SquareMeters { get; set; }
        public string? Details { get; set; }
        public bool IsAvailable { get; set; }
        public bool IsRentingPerDay { get; set; }
        public bool IsActiveOnApp { get; set; }
        public string? WhyRecommended { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
    }
}
