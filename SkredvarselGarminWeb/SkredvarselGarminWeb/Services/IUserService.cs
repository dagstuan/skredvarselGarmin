using SkredvarselGarminWeb.ServiceModels;

namespace SkredvarselGarminWeb.Services;

public interface IUserService
{
    Task RegisterLogin(UserLogin user);
}
