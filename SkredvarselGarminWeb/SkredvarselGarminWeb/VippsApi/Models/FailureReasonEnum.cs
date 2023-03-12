using System.Runtime.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models;

public enum FailureReasonEnum
{
    /// <summary>
    /// Enum UserActionRequired for value: user_action_required
    /// </summary>
    [EnumMember(Value = "user_action_required")]
    UserActionRequired = 1,

    /// <summary>
    /// Enum ChargeAmountTooHigh for value: charge_amount_too_high
    /// </summary>
    [EnumMember(Value = "charge_amount_too_high")]
    ChargeAmountTooHigh = 2,

    /// <summary>
    /// Enum NonTechnicalError for value: non_technical_error
    /// </summary>
    [EnumMember(Value = "non_technical_error")]
    NonTechnicalError = 3,

    /// <summary>
    /// Enum TechnicalError for value: technical_error
    /// </summary>
    [EnumMember(Value = "technical_error")]
    TechnicalError = 4

}
