using System.Runtime.Serialization;
using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public class PatchAgreementRequest
{
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? ProductName { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? ProductDescription { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? MerchantAgreementUrl { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    [JsonConverter(typeof(JsonStringEnumMemberConverter))]
    public PatchAgreementStatus? Status { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public PatchAgreementPricing? Pricing { get; set; }
}

public class PatchAgreementPricing
{
    public int Amount { get; set; }
}

public enum PatchAgreementStatus
{
    [EnumMember(Value = "STOPPED")]
    Stopped = 1,
}
