using System;

namespace Rentify.Model.ResponseObjects
{
    public class AnswerResponse
    {
        public int Id { get; set; }

        public int QuestionId { get; set; }

        public int UserId { get; set; }
        public string? UserName { get; set; }

        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }
}