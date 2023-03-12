using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class Agreement
{
    [Key]
    public string Id { get; set; } = string.Empty;

    public AgreementStatus Status = AgreementStatus.PENDING;

    [Required]
    public string? UserId { get; set; }
    public User? User { get; set; }
}
