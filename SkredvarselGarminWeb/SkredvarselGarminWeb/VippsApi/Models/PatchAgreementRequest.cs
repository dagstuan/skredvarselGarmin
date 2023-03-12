using System.Runtime.Serialization;
using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class PatchAgreementRequest
{
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? ProductName { get; init; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? ProductDescription { get; init; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? MerchantAgreementUrl { get; init; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public PatchAgreementStatus? Status { get; init; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public PatchAgreementPricing? Pricing { get; init; }
}

public class PatchAgreementPricing
{
    public int Amount { get; init; }
}

public enum PatchAgreementStatus
{
    [EnumMember(Value = "STOPPED")]
    Stopped = 1,
}
