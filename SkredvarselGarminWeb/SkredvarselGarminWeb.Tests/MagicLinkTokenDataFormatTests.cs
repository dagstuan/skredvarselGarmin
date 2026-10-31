using AwesomeAssertions;

using Microsoft.AspNetCore.DataProtection;

using SkredvarselGarminWeb.MagicLink;

namespace SkredvarselGarminWeb.Tests;

public class MagicLinkTokenDataFormatTests
{
    private readonly MagicLinkTokenDataFormat _dataFormat = new(new EphemeralDataProtectionProvider());

    [Fact]
    public void Unprotect_should_keep_expiration_time_from_when_the_token_was_created()
    {
        var token = new MagicLinkToken
        {
            Email = "test@example.com",
            UserId = null,
            ReturnUrl = "/en/account",
            ExpirationTime = DateTime.UtcNow.AddMinutes(-1),
        };

        var unprotected = _dataFormat.Unprotect(_dataFormat.Protect(token));

        unprotected.Should().NotBeNull();
        unprotected!.ExpirationTime.Should().Be(token.ExpirationTime);
        unprotected.ReturnUrl.Should().Be("/en/account");
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("not base64!")]
    [InlineData("dGFtcGVyZWQ=")]
    public void Unprotect_should_return_null_for_invalid_tokens(string? token)
    {
        _dataFormat.Unprotect(token).Should().BeNull();
    }
}
