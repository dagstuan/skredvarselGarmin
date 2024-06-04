using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class UserInfo
{
    [JsonPropertyName("name")]
    public required string Name { get; init; }

    [JsonPropertyName("email")]
    public required string Email { get; init; }
}
