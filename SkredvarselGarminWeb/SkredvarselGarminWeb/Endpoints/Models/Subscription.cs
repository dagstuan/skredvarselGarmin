using System.Text.Json.Serialization;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Endpoints.Models;

public class Subscription
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public required AgreementStatus Status { get; init; }
    public required DateOnly? NextChargeDate { get; init; }
    public string? VippsConfirmationUrl { get; init; }
}
