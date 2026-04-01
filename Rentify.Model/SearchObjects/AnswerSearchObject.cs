using Rentify.Model.SearchObjects;

namespace Rentify.Model.SearchObjects
{
    public class AnswerSearchObject : BaseSearchObject
    {
        public int? QuestionId { get; set; }
        public int? UserId { get; set; }
        public string? FTS { get; set; }
    }
}