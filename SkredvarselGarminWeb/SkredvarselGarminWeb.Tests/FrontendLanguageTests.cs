using AwesomeAssertions;

using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Tests;

public class FrontendLanguageTests
{
    [Theory]
    [InlineData("en", "/en")]
    [InlineData("sv", "/sv")]
    [InlineData("no", "")]
    [InlineData(null, "")]
    [InlineData("//evil.example", "")]
    public void GetPathPrefix_should_only_allow_known_languages(string? lang, string expected)
    {
        FrontendLanguage.GetPathPrefix(lang).Should().Be(expected);
    }

    [Theory]
    [InlineData("/en/account?watchKey=abc", "/en")]
    [InlineData("/sv/konto", "/sv")]
    [InlineData("/en", "/en")]
    [InlineData("/account", "")]
    [InlineData("/english", "")]
    public void GetPathPrefixFromPath_should_read_language_prefix(string path, string expected)
    {
        FrontendLanguage.GetPathPrefixFromPath(path).Should().Be(expected);
    }
}
