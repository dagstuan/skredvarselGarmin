using System.Security.Claims;
using System.Security.Principal;
using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Database;

public static class DbContextUserExtensions
{
    public static User GetUserOrThrow(this SkredvarselDbContext dbContext, IIdentity? identity)
    {
        if (identity == null)
        {
            throw new Exception("Unauthenticated user.");
        }

        var email = ((ClaimsIdentity)identity).FindFirst("email")!.Value;

        return dbContext.Users.First(u => u.Email == email);
    }

    public static User? GetUserForWatchOrNull(this SkredvarselDbContext dbContext, string watchId)
    {
        return dbContext.Watches
            .Include(w => w.User)
            .FirstOrDefault(w => w.Id == watchId)?.User;
    }

    public static List<User> GetUsersNotLoggedInForAMonthWithoutAgreements(this SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider)
    {
        return dbContext.Users
            .Include(u => u.Agreements)
            .Where(u => u.LastLoggedIn < DateOnly.FromDateTime(dateTimeNowProvider.UtcNow.AddMonths(-1)) && !u.Agreements.Any())
            .ToList();
    }
}
