using System.Text.Json.Serialization;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Endpoints.Models;

public class SubscriptionResponse
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public required SubscriptionType SubscriptionType { get; init; }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public AgreementStatus? VippsAgreementStatus { get; init; }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public StripeSubscriptionStatus? StripeSubscriptionStatus { get; init; }

    public required DateOnly? NextChargeDate { get; init; }
    public string? VippsConfirmationUrl { get; init; }
}

public enum SubscriptionType
{
    Vipps,
    Stripe
}
