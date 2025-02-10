namespace SkredvarselGarminWeb.Entities.Extensions;

public static class AgreementExtensions
{
    public static void SetUserId(this Agreement agreement, string userId)
    {
        agreement.UserId = userId;
    }

    public static void RemoveCallbackIdAndWatchKey(this Agreement agreement)
    {
        agreement.CallbackId = null;
        agreement.WatchKey = null;
    }

    public static void SetAsActive(this Agreement agreement)
    {
        agreement.Status = AgreementStatus.ACTIVE;
        agreement.ConfirmationUrl = null;
    }

    public static void SetAsUnsubscribed(this Agreement agreement)
    {
        agreement.Status = AgreementStatus.UNSUBSCRIBED;
    }

    public static void SetAsStopped(this Agreement agreement)
    {
        agreement.Status = AgreementStatus.STOPPED;
        agreement.NextChargeDate = null;
        agreement.NextChargeAmount = null;
        agreement.NextChargeId = null;
    }
}
