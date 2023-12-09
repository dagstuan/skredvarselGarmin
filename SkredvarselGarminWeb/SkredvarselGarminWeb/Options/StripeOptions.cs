namespace SkredvarselGarminWeb.Options;

public class StripeOptions
{
    public string ApiKey { get; init; } = string.Empty;
    public string PriceId { get; init; } = string.Empty;
    public string WebhookSecret { get; init; } = string.Empty;
}
