using System;
using System.Collections.Generic;

public class UnavailableDatesResponse
{
    public int PropertyId { get; set; }
    public List<DateTime> Dates { get; set; }
}