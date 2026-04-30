using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class PropertyImageSearchObject : BaseSearchObject
    {
        public int? PropertyId { get; set; }
        public bool? IsMain { get; set; }
    }
}
