using System.Security.Claims;
using System.Text.Encodings.Web;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using Microsoft.Net.Http.Headers;
using SkredvarselGarminWeb.Database;

namespace SkredvarselGarminWeb.Configuration;

public partial class GarminAuthenticationHandler : AuthenticationHandler<GarminAuthenticationSchemeOptions>
{
    public GarminAuthenticationHandler(
        IOptionsMonitor<GarminAuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder,
        ISystemClock clock) : base(options, logger, encoder, clock)
    {
    }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        if (!Request.Headers.ContainsKey(HeaderNames.Authorization))
        {
            return Task.FromResult(AuthenticateResult.Fail("Header Not Found."));
        }

        var header = Request.Headers[HeaderNames.Authorization].ToString();
        var tokenMatch = GarminAuthenticationHeader().Match(header);

        if (tokenMatch.Success)
        {
            var watchId = tokenMatch.Groups["token"].Value;

            var dbContext = Request.HttpContext.RequestServices.GetRequiredService<SkredvarselDbContext>();

            var userForWatch = dbContext.GetUserForWatch(watchId);
            if (userForWatch == null)
            {
                return Task.FromResult(AuthenticateResult.Fail("Unknown watch."));
            }

            if (dbContext.DoesUserHaveActiveAgreement(userForWatch.Id))
            {
                var claims = new[] {
                    new Claim(ClaimTypes.NameIdentifier, userForWatch.Id),
                    new Claim(ClaimTypes.Email, userForWatch.Email),
                    new Claim(ClaimTypes.Name, userForWatch.Name)
                };

                var claimsIdentity = new ClaimsIdentity(claims, nameof(GarminAuthenticationHandler));

                var ticket = new AuthenticationTicket(
                        new ClaimsPrincipal(claimsIdentity), Scheme.Name);

                return Task.FromResult(AuthenticateResult.Success(ticket));
            }
        }

        return Task.FromResult(AuthenticateResult.Fail("Model is Empty"));
    }

    [GeneratedRegex("Garmin (?<token>.*)")]
    private static partial Regex GarminAuthenticationHeader();
}
