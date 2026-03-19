using AwesomeAssertions;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;

using NSubstitute;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.LavinprognoserApi;
using SkredvarselGarminWeb.LavinprognoserApi.Models;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Tests;

public class SwedishForecastAreaSeederTests
{
    [Fact]
    public async Task SeedAsync_should_only_persist_forecastable_swedish_areas()
    {
        var dbContextOptions = new DbContextOptionsBuilder<SkredvarselDbContext>()
            .UseInMemoryDatabase(nameof(SeedAsync_should_only_persist_forecastable_swedish_areas))
            .ConfigureWarnings(b => b.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .Options;

        await using var dbContext = new SkredvarselDbContext(dbContextOptions);
        await dbContext.Database.EnsureDeletedAsync();
        await dbContext.Database.EnsureCreatedAsync();

        dbContext.ForecastAreas.Add(new ForecastArea
        {
            Id = 999,
            Name = "Existing Swedish area",
            RegionType = 'A',
            Country = nameof(Country.SE),
            Area = CreatePolygon(),
        });
        await dbContext.SaveChangesAsync();

        var lavinprognoserApi = Substitute.For<ILavinprognoserApi>();
        lavinprognoserApi.GetLocationPolygons().Returns(Task.FromResult<IEnumerable<WfsFeature<LavinprognoserLocation>>>([
            CreateFeature(3),
            CreateFeature(12)
        ]));

        var sut = new SwedishForecastAreaSeeder(dbContext, lavinprognoserApi);

        await sut.SeedAsync();

        var areas = dbContext.ForecastAreas.OrderBy(area => area.Id).ToList();

        areas.Should().ContainSingle();
        areas[0].Id.Should().Be(12);
        areas[0].Country.Should().Be(nameof(Country.SE));
        areas[0].Name.Should().Be("Sodra Jamtland Vast");
    }

    [Fact]
    public async Task SeedAsync_should_replace_existing_swedish_areas_with_same_ids()
    {
        var dbContextOptions = new DbContextOptionsBuilder<SkredvarselDbContext>()
            .UseInMemoryDatabase(nameof(SeedAsync_should_replace_existing_swedish_areas_with_same_ids))
            .ConfigureWarnings(b => b.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .Options;

        await using var dbContext = new SkredvarselDbContext(dbContextOptions);
        await dbContext.Database.EnsureDeletedAsync();
        await dbContext.Database.EnsureCreatedAsync();

        dbContext.ForecastAreas.Add(new ForecastArea
        {
            Id = 12,
            Name = "Stale Swedish area",
            RegionType = 'A',
            Country = nameof(Country.SE),
            Area = CreatePolygon(),
        });
        await dbContext.SaveChangesAsync();

        var lavinprognoserApi = Substitute.For<ILavinprognoserApi>();
        lavinprognoserApi.GetLocationPolygons().Returns(Task.FromResult<IEnumerable<WfsFeature<LavinprognoserLocation>>>([
            CreateFeature(12)
        ]));

        var sut = new SwedishForecastAreaSeeder(dbContext, lavinprognoserApi);

        await sut.SeedAsync();

        var areas = dbContext.ForecastAreas.Where(area => area.Id == 12).ToList();

        areas.Should().ContainSingle();
        areas[0].Country.Should().Be(nameof(Country.SE));
        areas[0].Name.Should().Be("Sodra Jamtland Vast");
    }

    private static WfsFeature<LavinprognoserLocation> CreateFeature(int id) =>
        new()
        {
            Properties = new LavinprognoserLocation
            {
                Id = id,
            },
            Geometry = new WfsGeometry
            {
                Type = "Polygon",
                Coordinates =
                [
                    [
                        [500000, 7000000],
                        [500100, 7000000],
                        [500100, 7000100],
                        [500000, 7000100],
                        [500000, 7000000],
                    ]
                ]
            }
        };

    private static NetTopologySuite.Geometries.Polygon CreatePolygon()
    {
        var geometryFactory = new NetTopologySuite.Geometries.GeometryFactory(
            new NetTopologySuite.Geometries.PrecisionModel(),
            25833);
        var shell = geometryFactory.CreateLinearRing([
            new NetTopologySuite.Geometries.Coordinate(500000, 7000000),
            new NetTopologySuite.Geometries.Coordinate(500100, 7000000),
            new NetTopologySuite.Geometries.Coordinate(500100, 7000100),
            new NetTopologySuite.Geometries.Coordinate(500000, 7000100),
            new NetTopologySuite.Geometries.Coordinate(500000, 7000000),
        ]);

        return geometryFactory.CreatePolygon(shell);
    }
}
