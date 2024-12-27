using SkredvarselGarminWeb.NtfyApi;

namespace SkredvarselGarminWeb.Services;

public class NotificationService(INtfyApiClient ntfyApiClient) : INotificationService
{
    public async Task NotifyUserSubscribed()
    {
        await ntfyApiClient.SendNotification(
            "New subscription!",
            "A new user subscribed to Skredvarsel!"
        );
    }

    public async Task NotifyUserDeactivated()
    {
        await ntfyApiClient.SendNotification(
            "Subscription deactivated",
            "A user deactivated their subscription to Skredvarsel"
        );
    }

    public async Task NotifyUserReactivated()
    {
        await ntfyApiClient.SendNotification(
            "Subscription reactivated!",
            "A user reactivated their subscription to Skredvarsel"
        );
    }

    public async Task NotifyActivationFailed()
    {
        await ntfyApiClient.SendNotification(
            "Subscription activation failed!",
            "Failed to activate Vipps subscription to Skredvarsel"
        );
    }

    public async Task NotifyChargeFailed()
    {
        await ntfyApiClient.SendNotification(
            "Charge failed!",
            "Failed to charge user for Skredvarsel subscription"
        );
    }
}
