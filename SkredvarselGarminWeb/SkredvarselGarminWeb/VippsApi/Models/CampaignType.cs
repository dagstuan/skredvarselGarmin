using System.Runtime.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public enum CampaignType
{
    [EnumMember(Value = "PRICE_CAMPAIGN")]
    PriceCampaign = 1,

    [EnumMember(Value = "PERIOD_CAMPAIGN")]
    PeriodCampaign = 2,

    [EnumMember(Value = "EVENT_CAMPAIGN")]
    EventCampaign = 3,

    [EnumMember(Value = "FULL_FLEX_CAMPAIGN")]
    FullFlexCampaign = 4
}
