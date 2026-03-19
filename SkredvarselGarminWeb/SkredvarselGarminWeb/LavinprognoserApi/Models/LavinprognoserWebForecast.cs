using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.LavinprognoserApi.Models;

public class LavinprognoserWebResponse
{
    [JsonPropertyName("content")]
    public required LavinprognoserWebContent Content { get; init; }
}

public class LavinprognoserWebContent
{
    [JsonPropertyName("forecast")]
    public LavinprognoserWebForecast? Forecast { get; init; }
}

public class LavinprognoserWebForecast
{
    [JsonPropertyName("id")]
    public required int Id { get; init; }

    [JsonPropertyName("risk")]
    public required int Risk { get; init; }

    [JsonPropertyName("publishedDate")]
    public required string PublishedDate { get; init; }

    [JsonPropertyName("validFrom")]
    public required string ValidFrom { get; init; }

    [JsonPropertyName("validTo")]
    public required string ValidTo { get; init; }

    [JsonPropertyName("assessmentContent")]
    public string? AssessmentContent { get; init; }

    [JsonPropertyName("trend")]
    public LavinprognoserWebTrend? Trend { get; init; }

    [JsonPropertyName("avalancheProblem")]
    public LavinprognoserWebAvalancheProblemContainer? AvalancheProblemContainer { get; init; }
}

public class LavinprognoserWebAvalancheProblemContainer
{
    [JsonPropertyName("problems")]
    public IEnumerable<LavinprognoserWebProblem>? Problems { get; init; }
}

public class LavinprognoserWebTrend
{
    [JsonPropertyName("trendDate")]
    public required string Date { get; init; }
}

public class LavinprognoserWebProblem
{
    [JsonPropertyName("problemId")]
    public required int ProblemId { get; init; }

    [JsonPropertyName("altitude")]
    public LavinprognoserWebAltitude? Altitude { get; init; }

    [JsonPropertyName("direction")]
    public LavinprognoserWebDirection? Direction { get; init; }

    [JsonPropertyName("spread")]
    public LavinprognoserWebSpread? Spread { get; init; }
}

public class LavinprognoserWebAltitude
{
    [JsonPropertyName("altitudeMeterAboveTreeline")]
    public LavinprognoserWebAltitudeZone? AboveTreeline { get; init; }

    [JsonPropertyName("altitudeMeterTreeline")]
    public LavinprognoserWebAltitudeZone? Treeline { get; init; }

    [JsonPropertyName("altitudeMeterBelowTreeline")]
    public LavinprognoserWebAltitudeZone? BelowTreeline { get; init; }
}

public class LavinprognoserWebAltitudeZone
{
    [JsonPropertyName("state")]
    public bool State { get; init; }
}

public class LavinprognoserWebDirection
{
    [JsonPropertyName("northPanel")]
    public LavinprognoserWebPanel? North { get; init; }

    [JsonPropertyName("northEastPanel")]
    public LavinprognoserWebPanel? NorthEast { get; init; }

    [JsonPropertyName("eastPanel")]
    public LavinprognoserWebPanel? East { get; init; }

    [JsonPropertyName("southEastPanel")]
    public LavinprognoserWebPanel? SouthEast { get; init; }

    [JsonPropertyName("southPanel")]
    public LavinprognoserWebPanel? South { get; init; }

    [JsonPropertyName("southWestPanel")]
    public LavinprognoserWebPanel? SouthWest { get; init; }

    [JsonPropertyName("westPanel")]
    public LavinprognoserWebPanel? West { get; init; }

    [JsonPropertyName("northWestPanel")]
    public LavinprognoserWebPanel? NorthWest { get; init; }
}

public class LavinprognoserWebPanel
{
    [JsonPropertyName("state")]
    public bool State { get; init; }
}

public class LavinprognoserWebSpread
{
    [JsonPropertyName("spreadId")]
    public int SpreadId { get; init; }

    [JsonPropertyName("sensitivityId")]
    public int SensitivityId { get; init; }

    [JsonPropertyName("sizeMeterValue")]
    public int? SizeMeterValue { get; init; }
}
