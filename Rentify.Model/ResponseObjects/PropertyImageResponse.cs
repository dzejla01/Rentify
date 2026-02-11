using System;
using System.Collections.Generic;
using System.Text;

namespace Rentify.Model.ResponseObjects
{
    
        public class PropertyImageResponse
        {
            public int Id { get; set; }
            public int PropertyId { get; set; }
            public string PropertyImg { get; set; } = string.Empty;
            public bool IsMain { get; set; }
        }
    

}
