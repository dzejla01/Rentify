using System;

namespace Rentify.Model.ResponseObjects
{
    public class UserResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public DateTime? DateOfBirth { get; set; }
        public bool IsActive { get; set; }
        public bool IsVlasnik { get; set; }
        public string UserImage { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public string? PhoneNumber { get; set; }
    }
}
