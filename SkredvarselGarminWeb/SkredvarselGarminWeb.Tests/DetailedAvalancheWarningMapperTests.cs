using AwesomeAssertions;

using SkredvarselGarminWeb.Endpoints.Mappers;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Tests;

public class DetailedAvalancheWarningMapperTests
{
    private static VarsomDetailedAvalancheWarning CreateWarning(
        string? snowSurface = null,
        string? currentWeaklayers = null,
        string? latestAvalancheActivity = null,
        string? latestObservations = null,
        VarsomMountainWeather? mountainWeather = null) => new()
        {
            PublishTime = new DateTime(2026, 3, 11, 15, 39, 23),
            ValidFrom = new DateTime(2026, 3, 12),
            ValidTo = new DateTime(2026, 3, 12, 23, 59, 59),
            DangerLevel = "3",
            MainText = "Main text",
            AvalancheProblems = [],
            EmergencyWarning = "Ikke gitt",
            IsTendency = false,
            SnowSurface = snowSurface,
            CurrentWeaklayers = currentWeaklayers,
            LatestAvalancheActivity = latestAvalancheActivity,
            LatestObservations = latestObservations,
            MountainWeather = mountainWeather,
        };

    [Fact]
    public void ToDetailedAvalancheWarning_should_not_include_snowpack_and_weather_by_default()
    {
        var warning = CreateWarning(
            snowSurface: "Snow surface.",
            mountainWeather: new VarsomMountainWeather { CloudCoverName = "Skyet" });

        var result = warning.ToDetailedAvalancheWarning("1");

        result.SnowpackHistory.Should().BeNull();
        result.MountainWeather.Should().BeNull();
    }

    [Fact]
    public void ToDetailedAvalancheWarning_should_join_snowpack_history_paragraphs_with_newlines()
    {
        var warning = CreateWarning(
            snowSurface: "Det kom 10 cm nysnø. ",
            currentWeaklayers: "Det finst eit svakt lag av kantkorn",
            latestAvalancheActivity: null,
            latestObservations: "Snøoverflata var vindpakka men mjuk, ");

        var result = warning.ToDetailedAvalancheWarning("1", includeSnowpackAndWeather: true);

        result.SnowpackHistory.Should().Be(
            "Det kom 10 cm nysnø.\nDet finst eit svakt lag av kantkorn.\nSnøoverflata var vindpakka men mjuk,");
    }

    [Fact]
    public void ToDetailedAvalancheWarning_should_join_mountain_weather_in_sort_order_with_cloud_cover_and_comment()
    {
        var warning = CreateWarning(mountainWeather: new VarsomMountainWeather
        {
            CloudCoverName = "Skyet",
            Comment = "Mulighet for sterk kuling midt på dagen. ",
            MeasurementTexts =
            [
                new VarsomMeasurementText { SortOrder = 30, Text = "Stiv kuling fra sørvest." },
                new VarsomMeasurementText { SortOrder = 10, Text = "25 mm i døgnet." },
                new VarsomMeasurementText { SortOrder = 40, Text = "-8 °C til -2 °C på 1800 moh." },
            ],
        });

        var result = warning.ToDetailedAvalancheWarning("1", includeSnowpackAndWeather: true);

        result.MountainWeather.Should().Be(
            "25 mm i døgnet. Stiv kuling fra sørvest. -8 °C til -2 °C på 1800 moh. Skyet. Mulighet for sterk kuling midt på dagen.");
    }

    [Fact]
    public void ToDetailedAvalancheWarning_should_use_empty_strings_when_requested_but_missing()
    {
        var warning = CreateWarning();

        var result = warning.ToDetailedAvalancheWarning("1", includeSnowpackAndWeather: true);

        result.SnowpackHistory.Should().BeEmpty();
        result.MountainWeather.Should().BeEmpty();
    }
}
