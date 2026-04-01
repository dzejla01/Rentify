using System;

namespace Rentify.Model.ResponseObjects
{
    public class QuestionResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public UserResponse? User {get; set;}
        public int PropertyId { get; set; }
        public PropertyResponse? Property {get; set;}
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public bool IsAnswered { get; set; }
    }
}