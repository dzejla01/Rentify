using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rentify.Services.Database
{
    public class Property
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(UserId))]
        public int UserId { get; set; } 
        public User User { get; set; }
        public string Name { get; set; }
        public string Location { get; set; }
        public string City { get; set; }
        public double PricePerDay { get; set; }
        public double PricePerMonth { get; set; }
        public List<string> Tags { get; set; }
        public string NumberOfsquares { get; set; }
        public string Details { get; set; }
        public bool IsAvailable { get; set; }
        public bool IsRentingPerDay {get; set;}
        public bool IsActiveOnApp { get; set; }
    }
}
