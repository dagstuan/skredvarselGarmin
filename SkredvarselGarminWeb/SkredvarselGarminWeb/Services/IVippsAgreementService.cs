namespace SkredvarselGarminWeb.Services;

public interface IVippsAgreementService
{
    Task UpdateAgreementCharges(string agreementId);
    Task DeactivateAgreement(string agreementId);
    Task ReactivateAgreement(string agreementId);
    Task PopulateNextChargeAmount(string agreementId);

    // TODO: Remove
    Task RemoveNextChargeOlderThan180Days(string agreementId);

    Task CreateNextChargeForAgreement(string agreementId);
}
