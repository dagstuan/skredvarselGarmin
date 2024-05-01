using System.Security.Claims;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Extensions;
using SkredvarselGarminWeb.Helpers;

namespace SkredvarselGarminWeb.Services;

public class UserService(
    SkredvarselDbContext dbContext,
    IDateTimeNowProvider dateTimeNowProvider) : IUserService
{
    public User GetUserOrThrow(ClaimsPrincipal principal)
    {
        return dbContext.GetUserOrThrow(principal);
    }

    public User GetUserOrRegisterLogin(ClaimsPrincipal principal)
    {
        var user = dbContext.GetUserOrNull(principal);

        if (user == null)
        {
            RegisterLogin(principal);
        }

        return dbContext.GetUserOrThrow(principal);
    }

    public void RegisterLogin(ClaimsPrincipal user)
    {
        var dateNow = DateOnly.FromDateTime(dateTimeNowProvider.Now);

        var id = user.Claims.GetClaimValue("sub");
        var name = user.Claims.GetClaimValueOrNull("name");
        var email = user.Claims.GetClaimValue("email");

        var dbUser = dbContext.GetUserByEmailOrNull(email);
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

        dbContext.SaveChanges();
    }
}
