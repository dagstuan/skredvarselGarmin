using System.Runtime.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public enum ChargeType
{
    [EnumMember(Value = "INITIAL")]
    INITIAL = 1,

    [EnumMember(Value = "RECURRING")]
    RECURRING = 2
}
