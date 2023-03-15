namespace SkredvarselGarminWeb.Entities.Extensions;

public static class AgreementExtensions
{
    public static bool IsActive(this Agreement agreement) =>
        agreement.Status == AgreementStatus.ACTIVE;

    public static void SetAsActive(this Agreement agreement)
    {
        agreement.Status = AgreementStatus.ACTIVE;
        agreement.ConfirmationUrl = null;
    }
}
