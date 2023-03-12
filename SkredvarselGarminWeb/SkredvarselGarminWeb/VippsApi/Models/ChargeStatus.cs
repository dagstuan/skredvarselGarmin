using System.Runtime.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public enum ChargeStatus
{
    [EnumMember(Value = "PENDING")]
    PENDING = 1,

    [EnumMember(Value = "DUE")]
    DUE = 2,

    [EnumMember(Value = "RESERVED")]
    RESERVED = 3,

    [EnumMember(Value = "CHARGED")]
    CHARGED = 4,

    [EnumMember(Value = "PARTIALLY_CAPTURED")]
    PARTIALLYCAPTURED = 5,

    [EnumMember(Value = "FAILED")]
    FAILED = 6,

    [EnumMember(Value = "CANCELLED")]
    CANCELLED = 7,

    [EnumMember(Value = "PARTIALLY_REFUNDED")]
    PARTIALLYREFUNDED = 8,

    [EnumMember(Value = "REFUNDED")]
    REFUNDED = 9,

    [EnumMember(Value = "PROCESSING")]
    PROCESSING = 10
}
