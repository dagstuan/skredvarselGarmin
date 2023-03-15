namespace SkredvarselGarminWeb.Services;

public interface ISubscriptionService
{
    Task UpdateAgreementCharges(string agreementId);
    Task DeactivateAgreement(string agreementId);
    Task ReactivateAgreement(string agreementId);
}
