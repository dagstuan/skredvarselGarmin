using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.Endpoints.Models;

public class SetupSubscriptionResponse
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public required SetupSubscriptionStatus Status { get; init; }
    public string? AddWatchKey { get; init; }
}
