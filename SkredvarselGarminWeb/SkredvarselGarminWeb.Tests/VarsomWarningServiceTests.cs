using AwesomeAssertions;

using Microsoft.Extensions.Caching.Memory;

using NSubstitute;

using SkredvarselGarminWeb.Services;
using SkredvarselGarminWeb.VarsomApi;
using SkredvarselGarminWeb.VarsomApi.Models;

namespace SkredvarselGarminWeb.Tests;

public class VarsomWarningServiceTests
{
    [Fact]
    public async Task GetDetailedWarningsByRegion_should_cache_identical_requests()
    {
        var from = new DateOnly(2026, 3, 18);
        var to = new DateOnly(2026, 3, 19);
        var expectedWarnings = new[]
        {
            new VarsomDetailedAvalancheWarning
            {
                PublishTime = from.ToDateTime(TimeOnly.MinValue),
                ValidFrom = from.ToDateTime(TimeOnly.MinValue),
                ValidTo = to.ToDateTime(TimeOnly.MinValue),
                DangerLevel = "2",
                MainText = "Cached warning",
                AvalancheProblems = [],
                EmergencyWarning = string.Empty,
                IsTendency = false,
            }
        };

        var varsomApi = Substitute.For<IVarsomApi>();
        varsomApi.GetDetailedWarningsByRegion(3012, "en", from, to)
            .Returns(Task.FromResult<IEnumerable<VarsomDetailedAvalancheWarning>>(expectedWarnings));

        var sut = new VarsomWarningService(varsomApi, new MemoryCache(new MemoryCacheOptions()));

        var first = (await sut.GetDetailedWarningsByRegion(3012, "en", from, to)).ToList();
        var second = (await sut.GetDetailedWarningsByRegion(3012, "en", from, to)).ToList();

        first.Should().BeEquivalentTo(expectedWarnings);
        second.Should().BeEquivalentTo(expectedWarnings);
        await varsomApi.Received(1).GetDetailedWarningsByRegion(3012, "en", from, to);
    }
}
