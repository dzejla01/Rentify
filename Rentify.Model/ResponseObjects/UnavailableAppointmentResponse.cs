using System;
using System.Collections.Generic;

namespace Rentify.Model.ResponseObjects
{
    public class UnavailableAppointmentsResponse
    {
        public int PropertyId { get; set; }

        public List<DateTime> DateTimes { get; set; }
    }
}