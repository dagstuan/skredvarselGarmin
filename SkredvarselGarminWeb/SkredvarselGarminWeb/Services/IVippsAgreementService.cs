namespace SkredvarselGarminWeb.Services;

public interface IVippsAgreementService
{
    Task UpdateAgreementCharges(string agreementId);
    Task DeactivateAgreement(string agreementId);
    Task ReactivateAgreement(string agreementId);
}
