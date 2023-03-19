using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class WatchAddRequest
{
    [Key]
    [Required]
    public required string WatchId { get; init; }

    [Required]
    public required string PartNumber { get; init; }

    [Required]
    public required string Key { get; init; }

    public required DateTime Created { get; init; }
}
