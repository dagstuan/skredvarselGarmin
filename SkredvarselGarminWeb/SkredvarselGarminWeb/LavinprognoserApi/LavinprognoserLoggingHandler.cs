namespace SkredvarselGarminWeb.LavinprognoserApi;

public class LavinprognoserLoggingHandler(ILogger<LavinprognoserLoggingHandler> logger) : DelegatingHandler
{
    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        logger.LogInformation("Lavinprognoser request: {Method} {Url}", request.Method, request.RequestUri);
        return base.SendAsync(request, cancellationToken);
    }
}
