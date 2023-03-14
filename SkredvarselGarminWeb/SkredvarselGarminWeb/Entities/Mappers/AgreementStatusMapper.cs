using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;

namespace SkredvarselGarminWeb.Entities.Mappers;

public static class AgreementStatusMapper
{
    public static AgreementStatus ToAgreementStatus(this VippsAgreementStatus status) => status switch
    {
        VippsAgreementStatus.Active => AgreementStatus.ACTIVE,
        VippsAgreementStatus.Expired => AgreementStatus.EXPIRED,
        VippsAgreementStatus.Pending => AgreementStatus.PENDING,
        VippsAgreementStatus.Stopped => AgreementStatus.STOPPED,
        _ => throw new NotImplementedException(),
    };
}
