using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class StripeCheckoutSessionFulfillment
{
    [Key]
    public required string SessionId { get; set; }

    public required DateTime FulfilledAt { get; set; }
    public required string SubscriptionId { get; set; }

    public required string UserId { get; set; }
    public User User { get; set; } = null!;
}
