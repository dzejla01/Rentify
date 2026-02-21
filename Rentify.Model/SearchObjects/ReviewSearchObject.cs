using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {

        public bool? IncludeUser { get; set; }
        public bool? IncludeProperty { get; set; }
    }
}
