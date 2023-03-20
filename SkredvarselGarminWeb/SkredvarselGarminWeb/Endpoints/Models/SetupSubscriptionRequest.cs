using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Endpoints.Models;

public class SetupSubscriptionRequest
{
    public required string WatchId { get; init; }

    [Required]
    public required string PartNumber { get; init; }
}
