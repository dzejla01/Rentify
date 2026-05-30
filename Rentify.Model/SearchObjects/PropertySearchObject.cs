namespace Rentify.Model.SearchObjects
{
    public class PropertySearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public string? Name { get; set; }
        public int? CityId { get; set; }
        public int? BuildingTypeId { get; set; }
        public bool? IsActiveOnApp { get; set; }
        public decimal? MinPriceMonth { get; set; }
        public decimal? MaxPriceMonth { get; set; }
        public decimal? MinPriceDays { get; set; }
        public decimal? MaxPriceDays { get; set; }

        public bool? IncludeUser { get; set; }
    }
}
