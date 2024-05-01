using System.Security.Claims;

using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public interface IUserService
{
    User GetUserOrThrow(ClaimsPrincipal principal);

    User GetUserOrRegisterLogin(ClaimsPrincipal principal);

    void RegisterLogin(ClaimsPrincipal user);
}
