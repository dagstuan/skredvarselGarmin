namespace SkredvarselGarminWeb.Extensions;

public static class HttpContextExtensions
{
    public static string GetBaseUrl(this HttpContext ctx) => $"{ctx.Request.Scheme}://{ctx.Request.Host}";
}
