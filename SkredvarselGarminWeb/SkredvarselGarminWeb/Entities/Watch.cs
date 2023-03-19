using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class Watch
{
    [Key]
    [Required]
    public required string Id { get; set; }

    [Required]
    public required string PartNumber { get; set; }

    [Required]
    public required string UserId { get; set; }

    public User User { get; set; } = null!;
}
