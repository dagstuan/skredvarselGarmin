namespace SkredvarselGarminWeb.Entities.Extensions;

public static class AgreementExtensions
{
    public static void SetUserIdAndRemoveCallbackId(this Agreement agreement, string userId)
    {
        agreement.UserId = userId;
        agreement.CallbackId = null;
    }

    public static void SetAsActive(this Agreement agreement)
    {
        agreement.Status = AgreementStatus.ACTIVE;
        agreement.ConfirmationUrl = null;
    }

    public static void SetAsStopped(this Agreement agreement)
    {
        agreement.Status = AgreementStatus.STOPPED;
        agreement.NextChargeDate = null;
        agreement.NextChargeAmount = null;
        agreement.NextChargeId = null;
    }
}
