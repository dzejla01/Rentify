using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rentify.Services.Database
{
    public class Review
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(ReservationId))]

        public int ReservationId { get; set; }
        public Reservation Reservation { get; set; }
        
        public string Comment { get; set; }
        public int StarRate { get; set; }

    }
}
