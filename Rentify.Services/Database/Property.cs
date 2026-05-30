using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Rentify.Services.Database
{
    public class Property
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; }
        public User User { get; set; }

        public string Name { get; set; }
        public string Location { get; set; }

        [ForeignKey(nameof(CityId))]
        public int CityId { get; set; }
        public City City { get; set; }

        [ForeignKey(nameof(BuildingTypeId))]
        public int BuildingTypeId { get; set; }
        public BuildingType BuildingType { get; set; }

        public decimal PricePerDay { get; set; }
        public decimal PricePerMonth { get; set; }
        public List<string> Tags { get; set; }
        public double SquareMeters { get; set; }
        public string Details { get; set; }
        public bool IsRentingPerDay { get; set; }
        public bool IsActiveOnApp { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
    }
}
