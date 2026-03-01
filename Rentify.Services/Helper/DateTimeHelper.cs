public static class DateTimeHelper
{
    public static DateTime ToUtcDate(DateTime d)
    {
        // radi i za Unspecified i za Local
        var utc = d.Kind == DateTimeKind.Utc ? d : d.ToUniversalTime();
        return new DateTime(utc.Year, utc.Month, utc.Day, 0, 0, 0, DateTimeKind.Utc);
    }

    public static DateTime? ToUtcDate(DateTime? d) => d.HasValue ? ToUtcDate(d.Value) : null;
}