using System.Runtime.Serialization;
using System.Text.Json.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum AgreementStatus
{
    [EnumMember(Value = "ACTIVE")]
    Active = 1,

    [EnumMember(Value = "PENDING")]
    Pending = 2,

    [EnumMember(Value = "STOPPED")]
    Stopped = 3,

    [EnumMember(Value = "EXPIRED")]
    Expired = 4,
}
