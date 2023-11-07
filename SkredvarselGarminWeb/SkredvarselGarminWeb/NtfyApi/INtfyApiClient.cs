using Refit;

namespace SkredvarselGarminWeb.NtfyApi;

public interface INtfyApiClient
{
    [Post("/")]
    Task SendNotification([Header("Title")] string title, [Body] string message);
}
