using System;

namespace Rentify.Model.ResponseObjects
{
    public class FavoriteResponse
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public UserResponse? User { get; set; }

        public int PropertyId { get; set; }
        public PropertyResponse? Property { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}