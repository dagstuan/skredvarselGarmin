using System.Web;

using Microsoft.Extensions.Options;

using Resend;

using SkredvarselGarminWeb.Options;

namespace SkredvarselGarminWeb.Services;

public class EmailService : IEmailService
{
    private readonly IResend _resend;
    private readonly IWebHostEnvironment _environment;
    private readonly AppOptions _appOptions;

    public EmailService(IResend resend, IWebHostEnvironment environment, IOptions<AppOptions> appOptions)
    {
        _resend = resend;
        _environment = environment;
        _appOptions = appOptions.Value;
    }

    public async Task SendLoginEmail(string email, string token)
    {
        string filePath = Path.Combine(_environment.ContentRootPath, "Templates", "LoginMailTemplate.html");
        var template = await File.ReadAllTextAsync(filePath);

        var urlEncodedToken = HttpUtility.UrlEncode(token);
        var loginUrl = $"{_appOptions.BaseUrl}/email-login?token={urlEncodedToken}";

        var message = new EmailMessage
        {
            From = "Skredvarsel for Garmin <login@skredvarsel.app>",
            To = email,
            Subject = "Innlogging til Skredvarsel for Garmin",
            HtmlBody = template.Replace("{loginUrl}", loginUrl)
        };

        await _resend.EmailSendAsync(message);
    }
}
