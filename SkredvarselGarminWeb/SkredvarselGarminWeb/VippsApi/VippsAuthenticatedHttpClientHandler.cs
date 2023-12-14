using System.Net.Http.Headers;
using Microsoft.Extensions.Options;
using System.Text.Json;
using SkredvarselGarminWeb.Options;
using SkredvarselGarminWeb.VippsApi.Models;

namespace SkredvarselGarminWeb.VippsApi;

public class VippsAuthenticatedHttpClientHandler(
    VippsAuthTokenStore authTokenStore,
    IOptions<VippsOptions> vippsOptions,
    ILogger<VippsAuthenticatedHttpClientHandler> logger) : DelegatingHandler
{
    private readonly VippsOptions _vippsOptions = vippsOptions.Value;

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = await GetToken();

        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", $"{token.AccessToken}");

        request.Headers.Add("Ocp-Apim-Subscription-Key", _vippsOptions.SubscriptionKey);
        request.Headers.Add("Merchant-Serial-Number", _vippsOptions.MerchantSerialNumber);
        request.Headers.Add("Vipps-System-Name", "Skredvarsel.app");
        request.Headers.Add("Vipps-System-Version", "0.0.1");

        return await base.SendAsync(request, cancellationToken).ConfigureAwait(false);
    }

    private async Task<AuthTokenResponse> GetToken()
    {
        var token = authTokenStore.AuthToken;
        if (token != null && !token.IsExpired())
        {
            return token;
        }

        AuthTokenResponse? authenticationResponse;
        var client = new HttpClient
        {
            BaseAddress = new Uri(_vippsOptions.BaseUrl)
        };

        client.DefaultRequestHeaders.Clear();
        client.DefaultRequestHeaders.Add("client_id", _vippsOptions.ClientId);
        client.DefaultRequestHeaders.Add("client_secret", _vippsOptions.ClientSecret);
        client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", _vippsOptions.SubscriptionKey);
        client.Timeout = TimeSpan.FromSeconds(5);
        try
        {
            var response = await client.PostAsync("/accessToken/get", null).ConfigureAwait(false);
            response.EnsureSuccessStatusCode();
            authenticationResponse =
                JsonSerializer.Deserialize<AuthTokenResponse>(await response.Content.ReadAsStringAsync());
            authTokenStore.AuthToken = authenticationResponse ?? throw new Exception("Failed to deserialize auth token");
        }

        catch (Exception ex)
        {
            logger.LogError(ex, $"Error getting vipps access token.");
            throw;
        }

        return authenticationResponse;
    }
}
