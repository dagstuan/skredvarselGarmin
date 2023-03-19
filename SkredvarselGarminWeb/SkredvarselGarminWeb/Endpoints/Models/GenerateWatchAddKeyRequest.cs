using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Endpoints.Models;

public class GenerateWatchAddKeyRequest
{
    public required string WatchId { get; init; }

    [Required]
    public required string PartNumber { get; init; }
}
