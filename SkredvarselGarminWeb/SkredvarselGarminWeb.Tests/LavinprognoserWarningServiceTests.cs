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

    [Fact]
    public async Task GetDetailedWarningsByArea_should_deduplicate_concurrent_requests_for_same_key()
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
        var gate = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
        var started = 0;

        lavinprognoserApi.GetDetailedWarningsByArea(12, from, to)
            .Returns(_ => DelayedWarnings());

        var sut = new LavinprognoserWarningService(lavinprognoserApi, new MemoryCache(new MemoryCacheOptions()));

        var firstTask = sut.GetDetailedWarningsByArea(12, from, to);
        var secondTask = sut.GetDetailedWarningsByArea(12, from, to);

        await Task.Delay(50);
        started.Should().Be(1);

        gate.SetResult();

        var results = await Task.WhenAll(firstTask, secondTask);

        results[0].Should().BeEquivalentTo(expectedWarnings);
        results[1].Should().BeEquivalentTo(expectedWarnings);
        await lavinprognoserApi.Received(1).GetDetailedWarningsByArea(12, from, to);

        async Task<IEnumerable<LavinprognoserDetailedWarning>> DelayedWarnings()
        {
            Interlocked.Increment(ref started);
            await gate.Task;
            return expectedWarnings;
        }
    }
}
