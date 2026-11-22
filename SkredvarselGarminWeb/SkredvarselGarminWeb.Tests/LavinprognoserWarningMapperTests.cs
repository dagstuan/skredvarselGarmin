using AwesomeAssertions;

using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.Tests;

public class LavinprognoserWarningMapperTests
{
    private static LavinprognoserWebForecast CreateForecast(string? snowInfo, string? weatherInfo) => new()
    {
        Id = 1,
        Risk = 2,
        PublishedDate = "2025-03-13T18:00:00",
        ValidFrom = "torsdag 13-03-2025 18:00",
        ValidTo = "fredag 14-03-2025 18:00",
        SnowInfo = snowInfo == null ? null : new LavinprognoserWebTextSection { Content = snowInfo },
        WeatherInfo = weatherInfo == null ? null : new LavinprognoserWebTextSection { Content = weatherInfo },
    };

    [Fact]
    public void HtmlToLines_should_put_bold_subheadings_in_divs_on_their_own_lines()
    {
        const string html =
            "<div><b></b></div><b>Fältarbete</b><div>Under torsdagen arbetade vi runt Tjäktjapasset.</div>" +
            "<div><br></div><div><b>Lavinaktivitet</b></div><div>Vi har inte sett några laviner.<div></div></div>";

        var result = LavinprognoserApi.LavinprognoserWarningMapper.HtmlToLines(html);

        result.Should().Be(
            "Fältarbete\nUnder torsdagen arbetade vi runt Tjäktjapasset.\nLavinaktivitet\nVi har inte sett några laviner.");
    }

    [Fact]
    public void HtmlToLines_should_split_spans_on_line_breaks()
    {
        const string html =
            "<span><strong>Fältarbete</strong><br></span> <span>Under fredagen arbetade vi\nnära Storlien.<br></span> " +
            "<span>&nbsp;<br></span> <span><strong>Lavinaktivitet</strong><br></span> <span>Inga nya laviner.</span>";

        var result = LavinprognoserApi.LavinprognoserWarningMapper.HtmlToLines(html);

        result.Should().Be("Fältarbete\nUnder fredagen arbetade vi nära Storlien.\nLavinaktivitet\nInga nya laviner.");
    }

    [Fact]
    public void HtmlToLines_should_remove_word_comments_and_decode_entities()
    {
        const string html =
            "<!--[if gte mso 9]><xml><o:OfficeDocumentSettings></o:OfficeDocumentSettings></xml><![endif]-->" +
            "<div>Natt mot fredag 15 till 20&nbsp;minusgrader.&nbsp;</div><div><br></div><div>Fredag  svag vind &amp; snöbyar.</div>";

        var result = LavinprognoserApi.LavinprognoserWarningMapper.HtmlToLines(html);

        result.Should().Be("Natt mot fredag 15 till 20 minusgrader.\nFredag svag vind & snöbyar.");
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("<div><br></div>")]
    public void HtmlToLines_should_return_empty_string_without_text(string? html)
    {
        LavinprognoserApi.LavinprognoserWarningMapper.HtmlToLines(html).Should().BeEmpty();
    }

    [Fact]
    public void ToDetailedWarning_should_map_snow_and_weather_info()
    {
        var forecast = CreateForecast(
            snowInfo: "<div><b>Lavinaktivitet</b></div><div>Inga laviner.</div>",
            weatherInfo: "<div>Fredag svag vind.</div>");

        var result = forecast.ToDetailedWarning();

        result.SnowpackHistory.Should().Be("Lavinaktivitet\nInga laviner.");
        result.MountainWeather.Should().Be("Fredag svag vind.");
    }

    [Fact]
    public void ToDetailedAvalancheWarning_should_only_include_snowpack_and_weather_when_requested()
    {
        var warning = CreateForecast(snowInfo: "<div>Snö.</div>", weatherInfo: null).ToDetailedWarning();

        var excluded = warning.ToDetailedAvalancheWarning();
        var included = warning.ToDetailedAvalancheWarning(includeSnowpackAndWeather: true);

        excluded.SnowpackHistory.Should().BeNull();
        excluded.MountainWeather.Should().BeNull();
        included.SnowpackHistory.Should().Be("Snö.");
        included.MountainWeather.Should().BeEmpty();
    }
}
