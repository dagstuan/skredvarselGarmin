using System.Runtime.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public enum ChargeEventEvent
{
    [EnumMember(Value = "CREATE")]
    CREATE = 1,

    [EnumMember(Value = "RESERVE")]
    RESERVE = 2,

    [EnumMember(Value = "CAPTURE")]
    CAPTURE = 3,

    [EnumMember(Value = "REFUND")]
    REFUND = 4,

    [EnumMember(Value = "CANCEL")]
    CANCEL = 5,

    [EnumMember(Value = "FAIL")]
    FAIL = 6
}
