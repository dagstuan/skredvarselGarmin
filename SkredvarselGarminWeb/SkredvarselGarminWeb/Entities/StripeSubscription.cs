using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class StripeSubscription
{
    [Key]
    public required string SubscriptionId { get; set; }
    public required DateTime Created { get; set; }

    public required StripeSubscriptionStatus Status { get; set; }
    public required DateOnly? NextChargeDate { get; set; }

    public required string UserId { get; set; }
    public User User { get; set; } = null!;
}
