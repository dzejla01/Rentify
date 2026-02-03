// Rentify.Model/Requests/UserUpsertRequest.cs
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class UserUpdateRequest
    {
        [Required, MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required, MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required, MaxLength(100), EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required, MaxLength(100)]
        public string Username { get; set; } = string.Empty;
        public DateTime? DateOfBirth { get; set; }

        // Kod update-a može biti null/empty ako ne mijenjaš šifru
        [MinLength(6)]
        public string? Password { get; set; }

        [Phone, MaxLength(20)]
        public string? PhoneNumber { get; set; }
        public string? UserImage { get; set; }

        public bool IsActive { get; set; } = true;

        // Opcionalno: role assignment preko roleId lista
        public List<int>? RoleIds { get; set; }
    }
}
