using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Endpoints.Models;

namespace SkredvarselGarminWeb.Endpoints;

public static class UserRouteBuilderExtensions
{
    public static void MapUserEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/api/user", async (
            HttpContext ctx,
            SkredvarselDbContext dbContext,
            IAuthorizationService authorizationService) =>
        {
            var result = await ctx.AuthenticateAsync();

            if (!result.Succeeded)
            {
                return Results.Ok(null);
            }
            else
            {
                var userInDb = dbContext.GetUserOrThrow(ctx.User.Identity);
                var isAdmin = await authorizationService.AuthorizeAsync(ctx.User, "Admin");
                return Results.Ok(new User
                {
                    Name = userInDb.Name,
                    Email = userInDb.Email,
                    IsAdmin = isAdmin?.Succeeded ?? false
                });
            }
        }).AllowAnonymous();
    }
}
