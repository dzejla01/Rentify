using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class QuestionSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? PropertyId { get; set; }
        public bool? IsAnswered { get; set; }
        public string? FTS { get; set; }

        public bool? IncludeUser {get; set;}
        public bool? IncludeProperty {get; set;}
    }
}