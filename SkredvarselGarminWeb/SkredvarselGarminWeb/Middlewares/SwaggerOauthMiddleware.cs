using Microsoft.AspNetCore.Authentication;

namespace SkredvarselGarminWeb.Middlewares;

public class SwaggerOAuthMiddleware(RequestDelegate next)
{
    private readonly RequestDelegate next = next;

    public async Task InvokeAsync(HttpContext context)
    {
        if (IsSwaggerUI(context.Request.Path))
        {
            // if user is not authenticated
            if (!context.User.Identity?.IsAuthenticated ?? false)
            {
                await context.ChallengeAsync();
                return;
            }
        }
        await next.Invoke(context);
    }
    public bool IsSwaggerUI(PathString pathString)
    {
        return pathString.StartsWithSegments("/swagger");
    }
}
