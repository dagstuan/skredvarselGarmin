using System.Security.Claims;
using System.Security.Principal;

using Microsoft.EntityFrameworkCore;

using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Extensions;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Database;

public static class DbContextUserExtensions
{
    public static User? GetUserOrNull(this SkredvarselDbContext dbContext, ClaimsPrincipal? principal)
    {
        if (principal == null)
        {
            return null;
        }

        var claims = principal.Claims;

        var email = claims.GetClaimValueOrNull("email");

        var user = dbContext.Users.FirstOrDefault(u => u.Email == email);

        if (user == null)
        {
            var sub = claims.GetClaimValueOrNull("sub");

            return dbContext.Users.FirstOrDefault(u => u.Id == sub);
        }

        return user;
    }

    public static User GetUserOrThrow(this SkredvarselDbContext dbContext, ClaimsPrincipal? principal)
    {
        return dbContext.GetUserOrNull(principal)
            ?? throw new Exception("Unable to find user for principal.");
    }

    public static User? GetUserByIdOrNull(this SkredvarselDbContext dbContext, string id)
    {
        return dbContext.Users.FirstOrDefault(u => u.Id == id);
    }

    public static User? GetUserByEmailOrNull(this SkredvarselDbContext dbContext, string email)
    {
        return dbContext.Users.FirstOrDefault(u => EF.Functions.ILike(u.Email, email));
    }

    public static User? GetUserForWatchOrNull(this SkredvarselDbContext dbContext, string watchId)
    {
        return dbContext.Watches
            .Include(w => w.User)
            .FirstOrDefault(w => w.Id == watchId)?.User;
    }

    public static List<User> GetUsersNotLoggedInForAMonthWithoutAgreements(this SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider)
    {
        return [.. dbContext.Users
            .Include(u => u.Agreements)
            .Include(u => u.StripeSubscriptions)
            .Where(u => u.LastLoggedIn < DateOnly.FromDateTime(dateTimeNowProvider.UtcNow.AddMonths(-1)) && u.Agreements.Count == 0 && u.StripeSubscriptions.Count == 0)];
    }
}
