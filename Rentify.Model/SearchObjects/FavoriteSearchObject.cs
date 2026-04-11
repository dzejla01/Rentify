using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class FavoriteSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? PropertyId { get; set; }

        public bool? IncludeUser { get; set; }
        public bool? IncludeProperty { get; set; }
        public bool? IncludePropertyOwner { get; set; }
    }
}