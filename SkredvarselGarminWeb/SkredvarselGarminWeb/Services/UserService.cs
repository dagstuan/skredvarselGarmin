using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Extensions;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Services;

public class UserService(
    SkredvarselDbContext dbContext,
    IDateTimeNowProvider dateTimeNowProvider) : IUserService
{
    public async Task RegisterLogin(ClaimsPrincipal user)
    {
        var dateNow = DateOnly.FromDateTime(dateTimeNowProvider.Now);

        var id = user.Claims.GetClaimValue("sub");
        var name = user.Claims.GetClaimValue("name");
        var email = user.Claims.GetClaimValue("email");

        var dbUser = await dbContext.Users.Where(u => u.Email == email).FirstOrDefaultAsync();
        if (dbUser == null)
        {
            dbUser = new User
            {
                Id = id,
                Name = name,
                Email = email,
                CreatedDate = dateNow,
                LastLoggedIn = dateNow
            };

            dbContext.Users.Add(dbUser);
        }

        dbUser.Name = name;
        dbUser.Email = email;
        dbUser.LastLoggedIn = dateNow;

        await dbContext.SaveChangesAsync();
    }
}
