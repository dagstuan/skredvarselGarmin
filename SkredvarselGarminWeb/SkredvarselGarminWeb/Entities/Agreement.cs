using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class Agreement
{
    [Key]
    public string Id { get; set; } = string.Empty;

    public AgreementStatus Status { get; set; } = AgreementStatus.PENDING;

    public string ConfirmationUrl { get; set; } = string.Empty;

    public DateOnly Start { get; set; } = DateOnly.MinValue;

    public string NextChargeId { get; set; } = string.Empty;
    public DateOnly NextChargeDate { get; set; }

    [Required]
    public string? UserId { get; set; }
    public User? User { get; set; }
}
