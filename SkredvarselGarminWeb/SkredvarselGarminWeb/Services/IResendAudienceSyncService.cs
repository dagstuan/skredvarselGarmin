namespace SkredvarselGarminWeb.Services;

public interface IResendAudienceSyncService
{
    Task SyncUsers(CancellationToken cancellationToken = default);
}
