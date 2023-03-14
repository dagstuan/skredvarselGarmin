using System.Runtime.Serialization;
using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public enum PeriodUnit
{
    [EnumMember(Value = "YEAR")]
    Year = 1,

    [EnumMember(Value = "MONTH")]
    Month = 2,

    [EnumMember(Value = "WEEK")]
    Week = 3,

    [EnumMember(Value = "DAY")]
    Day = 4
}
