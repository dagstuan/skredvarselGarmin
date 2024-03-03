using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using NetTopologySuite.Geometries;

namespace SkredvarselGarminWeb.Entities;

public class ForecastArea
{
    [Key]
    public required int Id { get; set; }
    public required string Name { get; set; }
    public required char RegionType { get; set; }

    [Column(TypeName = "geometry (polygon, 25833)")]
    public required Polygon Area { get; set; }
}
