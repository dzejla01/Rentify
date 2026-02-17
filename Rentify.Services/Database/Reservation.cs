using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rentify.Services.Database
{
    public class Reservation
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; }
        public User? User { get; set; }

        [ForeignKey(nameof(PropertyId))]
        public int PropertyId { get; set; }
        public Property? Property { get; set; }
        public bool IsMonthly { get; set; }
        public bool? IsApproved { get; set; }
        public DateTime CreatedAt {get; set;}
        public DateTime? StartDateOfRenting {get; set;}
        public DateTime? EndDateOfRenting {get; set;}

    }
}
