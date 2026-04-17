using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Database;

public static class DbContextSubscriptionSettingsExtensions
{
    public static SubscriptionSettings GetSubscriptionSettings(this SkredvarselDbContext dbContext)
    {
        return dbContext.SubscriptionSettings.Find(SubscriptionSettings.SingletonId)
            ?? new SubscriptionSettings();
    }

    public static SubscriptionSettings SetFormerSubscriberExtraMonths(this SkredvarselDbContext dbContext, int extraMonths)
    {
        var settings = dbContext.SubscriptionSettings.Find(SubscriptionSettings.SingletonId);

        if (settings == null)
        {
            settings = new SubscriptionSettings();
            dbContext.SubscriptionSettings.Add(settings);
        }

        settings.FormerSubscriberExtraMonths = extraMonths;

        return settings;
    }

    public static int GetFormerSubscriberExtraMonths(this SkredvarselDbContext dbContext)
    {
        var settings = dbContext.GetSubscriptionSettings();

        return settings.FormerSubscriberExtraMonths;
    }
}
