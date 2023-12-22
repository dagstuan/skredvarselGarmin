using System.Security.Claims;
using SkredvarselGarminWeb.Entities;

namespace SkredvarselGarminWeb.Services;

public interface IUserService
{
    Task<User> GetUserOrRegisterLogin(ClaimsPrincipal principal);

    Task RegisterLogin(ClaimsPrincipal user);
}
