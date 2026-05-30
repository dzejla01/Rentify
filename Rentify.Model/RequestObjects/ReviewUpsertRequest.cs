using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class ReviewUpsertRequest
    {

        [Required]
        public int ReservationId { get; set; }

        [Required]
        [MinLength(1)]
        public string Comment { get; set; } = null!;

        [Range(1, 5)]
        public int StarRate { get; set; }
    }
}
