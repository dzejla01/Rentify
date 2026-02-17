using System;
using System.ComponentModel.DataAnnotations;

namespace Rentify.Model.RequestObjects
{
    public class ReservationUpsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int PropertyId { get; set; }

        public bool IsMonthly { get; set; }

        public bool? IsApproved { get; set; }
        public DateTime? CreatedAt { get; set;}
        public DateTime? StartDateOfRenting {get; set;}
        public DateTime? EndDateOfRenting {get; set;}
    }
}
