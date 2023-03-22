using System.Security.Claims;
using System.Security.Principal;
using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Database;

public static class DbContextUserExtensions
{
    public static User GetUserOrThrow(this SkredvarselDbContext dbContext, IIdentity? identity)
    {
        if (identity == null)
        {
            throw new Exception("Unauthenticated user.");
        }

        var sub = ((ClaimsIdentity)identity).FindFirst("sub")!.Value;

        return dbContext.Users.First(u => u.Id == sub);
    }

    public static User? GetUserForWatchOrNull(this SkredvarselDbContext dbContext, string watchId)
    {
        return dbContext.Watches
            .Include(w => w.User)
            .FirstOrDefault(w => w.Id == watchId)?.User;
    }
}
