using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.Endpoints.Models;

public class CheckAddWatchResponse
{
    public required CheckAddWatchStatus Status { get; init; }
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum CheckAddWatchStatus
{
    ACTIVE_SUBSCRIPTION = 0,
    INACTIVE_SUBSCRIPTION = 1,
}
