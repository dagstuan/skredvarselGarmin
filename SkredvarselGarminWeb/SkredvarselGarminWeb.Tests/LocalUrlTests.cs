using AwesomeAssertions;

using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Tests;

public class LocalUrlTests
{
    [Theory]
    [InlineData("/", true)]
    [InlineData("/account", true)]
    [InlineData("/en/account?watchKey=abc", true)]
    [InlineData(null, false)]
    [InlineData("", false)]
    [InlineData("account", false)]
    [InlineData("https://evil.example", false)]
    [InlineData("//evil.example", false)]
    [InlineData("/\\evil.example", false)]
    public void IsLocal_should_only_accept_paths_on_this_site(string? url, bool expected)
    {
        LocalUrl.IsLocal(url).Should().Be(expected);
    }
}
