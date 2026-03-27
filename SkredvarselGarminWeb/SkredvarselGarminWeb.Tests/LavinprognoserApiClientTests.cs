using System.Globalization;
using System.Net;
using System.Text;
using System.Text.Json;

using AwesomeAssertions;

using Microsoft.Extensions.Caching.Memory;

using NSubstitute;

using Refit;

using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.Tests;

public class LavinprognoserApiClientTests
{
    private static readonly CultureInfo SwedishCulture = CultureInfo.GetCultureInfo("sv-SE");

    [Fact]
    public async Task GetDetailedWarningsByArea_should_return_forecast_for_hard_coded_slug()
    {
        var day = new DateOnly(2026, 3, 10);
        var validFrom = day.AddDays(-1).ToDateTime(new TimeOnly(18, 0));
        var validTo = day.ToDateTime(new TimeOnly(18, 0));
        var fetchPath = $"oversikt-alla-omraden/sodra_jamtlandsfjallen/sodra-jamtlandsfjallen-vast/index.json?forecast_date={day:yyyy-MM-dd}";

        var sut = CreateClient(
            new Dictionary<string, string>
            {
                [fetchPath] = $$"""
                {
                  "content": {
                    "forecast": {
                      "id": 123,
                      "risk": 2,
                      "publishedDate": "{{validFrom:yyyy-MM-dd}}",
                      "validFrom": "{{FormatSwedishDate(validFrom)}}",
                      "validTo": "{{FormatSwedishDate(validTo)}}",
                      "assessmentContent": "<p>Stable snowpack</p>",
                      "trend": null,
                      "avalancheProblem": {
                        "problems": []
                      }
                    }
                  }
                }
                """
            });

        var warnings = (await sut.GetDetailedWarningsByArea(12, day, day)).ToList();

        warnings.Should().ContainSingle();
        warnings[0].DangerLevel.Should().Be(2);
        warnings[0].MainText.Should().Be("Stable snowpack");
        warnings[0].ValidTo.Should().Be(validTo);
    }

    [Fact]
    public async Task GetDetailedWarningsByArea_should_use_redirect_target_forecast_when_child_slug_resolves_to_parent_forecast()
    {
        var day = new DateOnly(2026, 3, 10);
        var validFrom = day.AddDays(-1).ToDateTime(new TimeOnly(18, 0));
        var validTo = day.ToDateTime(new TimeOnly(18, 0));
        var childFetchPath = $"oversikt-alla-omraden/sodra_jamtlandsfjallen/sodra-jamtlandsfjallen-vast/index.json?forecast_date={day:yyyy-MM-dd}";
        var parentFetchPath = $"oversikt-alla-omraden/sodra_jamtlandsfjallen/index.json?forecast_date={day:yyyy-MM-dd}";

        var sut = CreateClient(
            new Dictionary<string, string>
            {
                [parentFetchPath] = $$"""
                {
                  "content": {
                    "forecast": {
                      "id": 456,
                      "risk": 3,
                      "publishedDate": "{{validFrom:yyyy-MM-dd}}",
                      "validFrom": "{{FormatSwedishDate(validFrom)}}",
                      "validTo": "{{FormatSwedishDate(validTo)}}",
                      "assessmentContent": "<p>Parent forecast after redirect</p>",
                      "trend": null,
                      "avalancheProblem": {
                        "problems": []
                      }
                    }
                  }
                }
                """
            },
                new Dictionary<string, HttpResponseMessage>
                {
                    [childFetchPath] = CreateRedirectResponse(parentFetchPath),
                });

        var warnings = (await sut.GetDetailedWarningsByArea(12, day, day)).ToList();

        warnings.Should().ContainSingle();
        warnings[0].DangerLevel.Should().Be(3);
        warnings[0].MainText.Should().Be("Parent forecast after redirect");
        warnings[0].ValidTo.Should().Be(validTo);
    }

    [Fact]
    public async Task GetDetailedWarningsByArea_should_return_zero_when_redirect_target_parent_has_no_forecast()
    {
        var requestedDay = new DateOnly(2026, 3, 16);
        var fetchPath = $"oversikt-alla-omraden/sodra_jamtlandsfjallen/sodra-jamtlandsfjallen-vast/index.json?forecast_date={requestedDay:yyyy-MM-dd}";
        var parentFetchPath = $"oversikt-alla-omraden/sodra_jamtlandsfjallen/index.json?forecast_date={requestedDay:yyyy-MM-dd}";

        var sut = CreateClient(
            new Dictionary<string, string>
            {
                [parentFetchPath] = """
                {
                  "content": {
                    "forecast": null
                  }
                }
                """
            },
                new Dictionary<string, HttpResponseMessage>
                {
                    [fetchPath] = CreateRedirectResponse(parentFetchPath),
                });

        var warnings = (await sut.GetDetailedWarningsByArea(12, requestedDay, requestedDay)).ToList();

        warnings.Should().ContainSingle();
        warnings[0].DangerLevel.Should().Be(0);
        warnings[0].MainText.Should().BeEmpty();
        warnings[0].ValidTo.Should().Be(requestedDay.ToDateTime(new TimeOnly(18, 0)));
    }

    [Fact]
    public async Task GetDetailedWarningsByArea_should_pad_missing_requested_days()
    {
        var from = new DateOnly(2026, 3, 16);
        var to = new DateOnly(2026, 3, 20);
        var availableDay = new DateOnly(2026, 3, 17);
        var validFrom = availableDay.AddDays(-1).ToDateTime(new TimeOnly(18, 0));
        var validTo = availableDay.ToDateTime(new TimeOnly(18, 0));
        var fetchPath = $"oversikt-alla-omraden/sodra_jamtlandsfjallen/sodra-jamtlandsfjallen-vast/index.json?forecast_date={availableDay:yyyy-MM-dd}";

        var sut = CreateClient(
            new Dictionary<string, string>
            {
                [fetchPath] = $$"""
                {
                  "content": {
                    "forecast": {
                      "id": 987,
                      "risk": 2,
                      "publishedDate": "{{validFrom:yyyy-MM-dd}}",
                      "validFrom": "{{FormatSwedishDate(validFrom)}}",
                      "validTo": "{{FormatSwedishDate(validTo)}}",
                      "assessmentContent": "<p>Available forecast</p>",
                      "trend": null,
                      "avalancheProblem": {
                        "problems": []
                      }
                    }
                  }
                }
                """
            });

        var warnings = (await sut.GetDetailedWarningsByArea(12, from, to)).ToList();

        warnings.Select(warning => DateOnly.FromDateTime(warning.ValidTo)).Should().Equal([
            new DateOnly(2026, 3, 16),
            new DateOnly(2026, 3, 17),
            new DateOnly(2026, 3, 18),
            new DateOnly(2026, 3, 19),
            new DateOnly(2026, 3, 20),
        ]);
        warnings.Single(warning => warning.ValidTo == validTo).DangerLevel.Should().Be(2);
        warnings.Where(warning => warning.ValidTo != validTo).Should().OnlyContain(warning => warning.DangerLevel == 0);
    }

    [Fact]
    public async Task GetDetailedWarningsByArea_should_return_empty_when_area_id_is_not_in_hard_coded_registry()
    {
        var wfsApi = Substitute.For<ILavinprognoserWfsApi>();
        var websiteApi = Substitute.For<ILavinprognoserWebsiteApi>();

        var sut = new LavinprognoserApiClient(
          wfsApi,
          websiteApi,
          new MemoryCache(new MemoryCacheOptions()));

        var warnings = await sut.GetDetailedWarningsByArea(999, new DateOnly(2026, 3, 10), new DateOnly(2026, 3, 10));

        warnings.Should().BeEmpty();
    }

    private static LavinprognoserApiClient CreateClient(
        IReadOnlyDictionary<string, string> responses,
        IReadOnlyDictionary<string, HttpResponseMessage>? customResponses = null)
    {
        var wfsApi = Substitute.For<ILavinprognoserWfsApi>();
        var websiteApi = Substitute.For<ILavinprognoserWebsiteApi>();

        websiteApi.GetForecastPage(Arg.Any<string>(), Arg.Any<string>())
            .Returns(callInfo => CreateForecastResponse(
                BuildForecastPath(callInfo.ArgAt<string>(0), null, callInfo.ArgAt<string>(1)),
                responses,
                customResponses));

        websiteApi.GetForecastPage(Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string>())
            .Returns(callInfo => CreateForecastResponse(
                BuildForecastPath(callInfo.ArgAt<string>(0), callInfo.ArgAt<string>(1), callInfo.ArgAt<string>(2)),
                responses,
                customResponses));

        wfsApi.GetAllLocationPolygons(Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string?>())
          .Returns(_ => CreateApiResponse<WfsFeatureCollection<JsonElement>>(new HttpResponseMessage(HttpStatusCode.NotFound), default));

        wfsApi.GetLocationPolygons(Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string?>())
          .Returns(_ => CreateApiResponse<WfsFeatureCollection<LavinprognoserLocation>>(new HttpResponseMessage(HttpStatusCode.NotFound), default));

        return new LavinprognoserApiClient(
          wfsApi,
          websiteApi,
          new MemoryCache(new MemoryCacheOptions()));
    }

    private static Task<ApiResponse<LavinprognoserWebResponse>> CreateForecastResponse(
        string pathAndQuery,
        IReadOnlyDictionary<string, string> responses,
        IReadOnlyDictionary<string, HttpResponseMessage>? customResponses)
    {
        if (customResponses != null && customResponses.TryGetValue(pathAndQuery, out var customResponse))
        {
            if (customResponse.RequestMessage == null)
            {
                customResponse.RequestMessage = new HttpRequestMessage(HttpMethod.Get, $"https://www.lavinprognoser.se/{pathAndQuery}");
            }

            return CreateApiResponse<LavinprognoserWebResponse>(customResponse, default);
        }

        if (!responses.TryGetValue(pathAndQuery, out var json))
        {
            return CreateApiResponse<LavinprognoserWebResponse>(new HttpResponseMessage(HttpStatusCode.NotFound)
            {
                RequestMessage = new HttpRequestMessage(HttpMethod.Get, $"https://www.lavinprognoser.se/{pathAndQuery}")
            }, default);
        }

        return CreateApiResponse(CreateJsonResponse(json, pathAndQuery), System.Text.Json.JsonSerializer.Deserialize<LavinprognoserWebResponse>(json));
    }

    private static Task<ApiResponse<T>> CreateApiResponse<T>(HttpResponseMessage response, T? content) =>
      Task.FromResult(new ApiResponse<T>(response, content, new RefitSettings(), null));

    private static string BuildForecastPath(string parentSlug, string? childSlug, string forecastDate)
    {
        var slug = childSlug == null ? parentSlug : $"{parentSlug}/{childSlug}";
        return $"oversikt-alla-omraden/{slug}/index.json?forecast_date={forecastDate}";
    }

    private static HttpResponseMessage CreateJsonResponse(string json, string pathAndQuery) => new(HttpStatusCode.OK)
    {
        Content = new StringContent(json, Encoding.UTF8, "application/json"),
        RequestMessage = new HttpRequestMessage(HttpMethod.Get, $"https://www.lavinprognoser.se/{pathAndQuery}")
    };

    private static HttpResponseMessage CreateRedirectResponse(string redirectedPath) => new(HttpStatusCode.OK)
    {
        Content = new StringContent("<html></html>", Encoding.UTF8, "text/html"),
        RequestMessage = new HttpRequestMessage(HttpMethod.Get, $"https://www.lavinprognoser.se/{redirectedPath}")
    };

    private static string FormatSwedishDate(DateTime value) =>
        value.ToString("dddd dd-MM-yyyy HH:mm", SwedishCulture);
}
