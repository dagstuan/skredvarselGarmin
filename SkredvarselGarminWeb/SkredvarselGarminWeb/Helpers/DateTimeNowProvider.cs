namespace SkredvarselGarminWeb.Helpers;

public interface IDateTimeNowProvider
{
    DateTime Now { get; }
    DateTime UtcNow { get; }
}

public class DateTimeNowProvider : IDateTimeNowProvider
{
    public DateTime Now => DateTime.Now;
    public DateTime UtcNow => DateTime.UtcNow;
}
