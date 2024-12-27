namespace SkredvarselGarminWeb.Services;

public interface INotificationService
{
    Task NotifyUserSubscribed();
    Task NotifyUserDeactivated();
    Task NotifyUserReactivated();
    Task NotifyActivationFailed();
    Task NotifyChargeFailed();
}
