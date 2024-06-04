namespace SkredvarselGarminWeb.Services;

public interface IEmailService
{
    Task SendLoginEmail(string email, string token);
}
