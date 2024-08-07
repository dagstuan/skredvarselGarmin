namespace SkredvarselGarminWeb.Services;

public interface IVippsAgreementService
{
    Task UpdateAgreementCharges(string agreementId);
    Task DeactivateAgreement(string agreementId);
    Task ReactivateAgreement(string agreementId);
    Task StopAgreement(string agreementId);
    Task CreateNextChargeForAgreement(string agreementId);
}
