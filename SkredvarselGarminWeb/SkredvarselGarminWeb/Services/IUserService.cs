using System.Security.Claims;

namespace SkredvarselGarminWeb.Services;

public interface IUserService
{
    Task RegisterLogin(ClaimsPrincipal user);
}
