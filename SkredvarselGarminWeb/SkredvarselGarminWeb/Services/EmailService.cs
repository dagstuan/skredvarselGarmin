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

    private record LoginEmailTexts(
        string HtmlLang,
        string Subject,
        string Preheader,
        string Heading,
        string Intro,
        string Button,
        string FallbackBefore,
        string FallbackLink,
        string NotYouTitle,
        string NotYouText);

    private static readonly LoginEmailTexts NorwegianLoginEmail = new(
        HtmlLang: "nb",
        Subject: "Innlogging til Skredvarsel for Garmin",
        Preheader: "Bruk lenken under for å logge inn på Skredvarsel for Garmin",
        Heading: "Logg inn på Skredvarsel for Garmin",
        Intro: "Trykk på knappen under for å logge inn på Skredvarsel for Garmin. Denne lenken vil utløpe innen 10 minutter.",
        Button: "Logg inn",
        FallbackBefore: "Hvis du har problemer med å trykke på knappen over,",
        FallbackLink: "trykk her",
        NotYouTitle: "Ikke deg?",
        NotYouText: "Hvis det ikke var du som prøvde å logge deg inn kan du trygt se bort fra denne eposten.");

    private static readonly LoginEmailTexts EnglishLoginEmail = new(
        HtmlLang: "en",
        Subject: "Sign in to Skredvarsel for Garmin",
        Preheader: "Use the following link to sign in to Skredvarsel for Garmin",
        Heading: "Sign in to Skredvarsel for Garmin",
        Intro: "Click the button below to sign in to Skredvarsel for Garmin. This link expires in 10 minutes.",
        Button: "Sign in",
        FallbackBefore: "If you have trouble clicking the button above,",
        FallbackLink: "click here",
        NotYouTitle: "Not you?",
        NotYouText: "If you didn't try to sign in, you can safely ignore this email.");

    private static readonly LoginEmailTexts SwedishLoginEmail = new(
        HtmlLang: "sv",
        Subject: "Logga in på Skredvarsel for Garmin",
        Preheader: "Använd länken nedan för att logga in på Skredvarsel for Garmin",
        Heading: "Logga in på Skredvarsel for Garmin",
        Intro: "Tryck på knappen nedan för att logga in på Skredvarsel for Garmin. Länken slutar gälla om 10 minuter.",
        Button: "Logga in",
        FallbackBefore: "Om du har problem med att trycka på knappen ovan,",
        FallbackLink: "tryck här",
        NotYouTitle: "Inte du?",
        NotYouText: "Om det inte var du som försökte logga in kan du lugnt bortse från det här mejlet.");

    public EmailService(IResend resend, IWebHostEnvironment environment, IOptions<AppOptions> appOptions)
    {
        _resend = resend;
        _environment = environment;
        _appOptions = appOptions.Value;
    }

    public async Task SendLoginEmail(string email, string token, string? lang)
    {
        string filePath = Path.Combine(_environment.ContentRootPath, "Templates", "LoginMailTemplate.html");
        var template = await File.ReadAllTextAsync(filePath);

        var urlEncodedToken = HttpUtility.UrlEncode(token);
        var loginUrl = $"{_appOptions.BaseUrl}/email-login?token={urlEncodedToken}";

        var texts = lang switch
        {
            "en" => EnglishLoginEmail,
            "sv" => SwedishLoginEmail,
            _ => NorwegianLoginEmail,
        };

        var htmlBody = template
            .Replace("{lang}", texts.HtmlLang)
            .Replace("{preheader}", texts.Preheader)
            .Replace("{heading}", texts.Heading)
            .Replace("{intro}", texts.Intro)
            .Replace("{button}", texts.Button)
            .Replace("{fallbackBefore}", texts.FallbackBefore)
            .Replace("{fallbackLink}", texts.FallbackLink)
            .Replace("{notYouTitle}", texts.NotYouTitle)
            .Replace("{notYouText}", texts.NotYouText)
            .Replace("{loginUrl}", loginUrl);

        var message = new EmailMessage
        {
            From = "Skredvarsel for Garmin <login@skredvarsel.app>",
            To = email,
            Subject = texts.Subject,
            HtmlBody = htmlBody
        };

        await _resend.EmailSendAsync(message);
    }
}
