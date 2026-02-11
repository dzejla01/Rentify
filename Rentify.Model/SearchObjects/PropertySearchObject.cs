namespace Rentify.Model.SearchObjects
{
    public class PropertySearchObject : BaseSearchObject
    {
        public int? UserId { get; set; } 
        public string? Name { get; set; }
        public string? Location { get; set; }
        public bool? IsAvailable { get; set; }
        public double? MinPrice { get; set; }
        public double? MaxPrice { get; set; }
    }
}
