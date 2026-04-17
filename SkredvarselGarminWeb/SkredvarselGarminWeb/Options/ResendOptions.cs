namespace SkredvarselGarminWeb.Options;

public class ResendOptions
{
    public string ApiToken { get; init; } = string.Empty;
    public bool EnableAudienceSync { get; init; } = true;
    public string FormerSubscribersSegmentName { get; init; } = "Former Subscribers";
}
