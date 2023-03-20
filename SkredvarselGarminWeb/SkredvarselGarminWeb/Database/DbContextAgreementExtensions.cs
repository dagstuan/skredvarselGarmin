using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Database;

public static class DbContextAgreementExtensions
{
    public static List<Agreement> GetAgreementsThatAreDue(this SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider) =>
        dbContext.Agreements
            .Where(a => DateOnly.FromDateTime(dateTimeNowProvider.Now) >= a.NextChargeDate)
            .ToList();
    public static List<Agreement> GetPendingAgreements(this SkredvarselDbContext dbContext) =>
        dbContext.Agreements
            .Where(a => a.Status == AgreementStatus.PENDING)
            .ToList();

    public static Agreement? GetActiveAgreementForUser(this SkredvarselDbContext dbContext, string userId) =>
        dbContext.Agreements.Where(a => a.UserId == userId)
            .FirstOrDefault(a => a.Status == AgreementStatus.ACTIVE || a.Status == AgreementStatus.UNSUBSCRIBED);

    public static bool DoesUserHaveActiveAgreement(this SkredvarselDbContext dbContext, string userId)
    {
        return dbContext.Agreements.Where(a => a.UserId == userId)
            .Any(a => a.Status == AgreementStatus.ACTIVE || a.Status == AgreementStatus.UNSUBSCRIBED);
    }
}
