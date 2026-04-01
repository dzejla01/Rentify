using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class FavoriteUpsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int PropertyId { get; set; }
    }
}