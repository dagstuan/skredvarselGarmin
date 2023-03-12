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
    public string TokenType { get; set; } = string.Empty;

    [JsonPropertyName("expires_in")]
    public string ExpiresIn { get; set; } = string.Empty;

    [JsonPropertyName("ext_expires_in")]
    public string ExtExpiresIn { get; set; } = string.Empty;

    [JsonPropertyName("expires_on")]
    public string ExpiresOn { get; set; } = string.Empty;

    [JsonPropertyName("not_before")]
    public string NorBefore { get; set; } = string.Empty;

    [JsonPropertyName("resource")]
    public string Resources { get; set; } = string.Empty;

    [JsonPropertyName("access_token")]
    public string AccessToken { get; set; } = string.Empty;

    public bool IsExpired()
    {
        // Add a few seconds to DateTime.Now because we'd rather refresh the token a bit too early
        return DateTime.Now.AddSeconds(30) > _createdAt.AddSeconds(Convert.ToInt32(ExpiresIn));
    }
}
