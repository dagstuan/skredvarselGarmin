using System.Security.Claims;

using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public interface IUserService
{
    User GetUserOrThrow(ClaimsPrincipal principal);

    User GetUserOrRegisterLogin(ClaimsPrincipal principal);

    /// <summary>
    /// Registers a login for a principal. Will create user in the database if it does not exist.
    /// </summary>
    /// <param name="principal">The user.</param>
    void RegisterLogin(ClaimsPrincipal user);
}
