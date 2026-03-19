using AwesomeAssertions;

using Microsoft.Extensions.Caching.Memory;

using NSubstitute;

using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.LavinprognoserApi.Models;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Tests;

public class LavinprognoserWarningServiceTests
{
    [Fact]
    public async Task GetDetailedWarningsByArea_should_cache_identical_requests()
    {
        var from = new DateOnly(2026, 3, 18);
        var to = new DateOnly(2026, 3, 19);
        var expectedWarnings = new[]
        {
            new LavinprognoserDetailedWarning
            {
                PublishTime = from.ToDateTime(TimeOnly.MinValue),
                ValidFrom = from.ToDateTime(TimeOnly.MinValue),
                ValidTo = to.ToDateTime(new TimeOnly(18, 0)),
                DangerLevel = 2,
                MainText = "Cached warning",
                IsTendency = false,
                AvalancheProblems = [],
            }
        };

        var lavinprognoserApi = Substitute.For<ILavinprognoserApi>();
        lavinprognoserApi.GetDetailedWarningsByArea(12, from, to)
            .Returns(Task.FromResult<IEnumerable<LavinprognoserDetailedWarning>>(expectedWarnings));

        var sut = new LavinprognoserWarningService(lavinprognoserApi, new MemoryCache(new MemoryCacheOptions()));

        var first = (await sut.GetDetailedWarningsByArea(12, from, to)).ToList();
        var second = (await sut.GetDetailedWarningsByArea(12, from, to)).ToList();

        first.Should().BeEquivalentTo(expectedWarnings);
        second.Should().BeEquivalentTo(expectedWarnings);
        await lavinprognoserApi.Received(1).GetDetailedWarningsByArea(12, from, to);
    }
}
