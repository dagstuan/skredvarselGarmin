using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class User
{
    [Key]
    [Required]
    public string Id { get; init; } = string.Empty;

    [Required]
    public string Name { get; init; } = string.Empty;

    [Required]
    public string Email { get; init; } = string.Empty;

    [Required]
    public DateOnly CreatedDate { get; init; } = DateOnly.FromDateTime(DateTime.Now);
}
