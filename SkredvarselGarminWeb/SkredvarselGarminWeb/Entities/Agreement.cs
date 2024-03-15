using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class Agreement
{
    [Key]
    public required string Id { get; set; }

    public required DateTime Created { get; set; }

    public required AgreementStatus Status { get; set; }

    public string? ConfirmationUrl { get; set; }

    public required DateOnly Start { get; set; }

    public string? NextChargeId { get; set; }
    public DateOnly? NextChargeDate { get; set; }
    public int? NextChargeAmount { get; set; }

    public required string UserId { get; set; }
    public User User { get; set; } = null!;
}
