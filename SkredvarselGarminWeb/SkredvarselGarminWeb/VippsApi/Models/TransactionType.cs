using System.Runtime.Serialization;

namespace SkredvarselGarminWeb.VippsApi.Models
{
    public enum TransactionType
    {
        [EnumMember(Value = "DIRECT_CAPTURE")]
        DIRECTCAPTURE = 1,

        [EnumMember(Value = "RESERVE_CAPTURE")]
        RESERVECAPTURE = 2
    }
}
