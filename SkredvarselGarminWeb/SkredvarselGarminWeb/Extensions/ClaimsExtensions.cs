using System.Security.Claims;

namespace SkredvarselGarminWeb.Extensions;

public static class ClaimsExtensions
{
    public static string GetClaimValue(this IEnumerable<Claim> claims, string claimType)
            => claims.First(c => c.Type == claimType).Value;

    public static string? GetClaimValueOrNull(this IEnumerable<Claim> claims, string claimType)
        => claims.FirstOrDefault(c => c.Type == claimType)?.Value;
}
