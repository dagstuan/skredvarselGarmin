using System.ComponentModel.DataAnnotations;

namespace SkredvarselGarminWeb.Entities;

public class SubscriptionSettings
{
    public const int SingletonId = 1;

    [Key]
    public int Id { get; set; } = SingletonId;

    public int FormerSubscriberExtraMonths { get; set; } = 0;
}