using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class AuthTokenResponse
{
    private readonly DateTime _createdAt;

    public AuthTokenResponse()
    {
        _createdAt = DateTime.Now;
    }

    [JsonPropertyName("token_type")]
    public required string TokenType { get; init; }

    [JsonPropertyName("expires_in")]
    public required string ExpiresIn { get; init; }

    [JsonPropertyName("ext_expires_in")]
    public required string ExtExpiresIn { get; init; }

    [JsonPropertyName("expires_on")]
    public required string ExpiresOn { get; init; }

    [JsonPropertyName("not_before")]
    public required string NorBefore { get; init; }

    [JsonPropertyName("resource")]
    public required string Resources { get; init; }

    [JsonPropertyName("access_token")]
    public required string AccessToken { get; init; }

    public bool IsExpired()
    {
        // Add a few seconds to DateTime.Now because we'd rather refresh the token a bit too early
        return DateTime.Now.AddSeconds(30) > _createdAt.AddSeconds(Convert.ToInt32(ExpiresIn));
    }
}
