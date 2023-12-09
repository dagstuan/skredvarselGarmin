using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class User
{
    [Key]
    [Required]
    public string Id { get; init; } = string.Empty;

    [Required]
    public string Name { get; set; } = string.Empty;

    [Required]
    public string Email { get; set; } = string.Empty;

    [Required]
    public required DateOnly LastLoggedIn { get; set; }

    [Required]
    public required DateOnly CreatedDate { get; init; }

    public string? StripeCustomerId { get; set; }

    public List<Agreement> Agreements { get; set; } = null!;

    public List<Watch> Watches { get; set; } = null!;

    public List<StripeSubscription> StripeSubscriptions { get; set; } = null!;
}
