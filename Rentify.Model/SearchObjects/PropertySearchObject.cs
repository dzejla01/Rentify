namespace Rentify.Model.SearchObjects
{
    public class PropertySearchObject : BaseSearchObject
    {
        public int? UserId { get; set; } 
        public string? Name { get; set; }
        public string? City { get; set; }
        public bool? IsAvailable { get; set; }
        public double? MinPriceMonth { get; set; }
        public double? MaxPriceMonth { get; set; }
        public double? MinPriceDays { get; set; }
        public double? MaxPriceDays { get; set; }
    }
}
