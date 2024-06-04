using System.Text.Json;

using Microsoft.AspNetCore.DataProtection;

namespace SkredvarselGarminWeb.MagicLink;

public class MagicLinkTokenDataFormat : IMagicLinkTokenDataFormat
{
    private readonly IDataProtector _dataProtector;

    public MagicLinkTokenDataFormat(IDataProtectionProvider dataProtectionProvider)
    {
        _dataProtector = dataProtectionProvider.CreateProtector("MagicLinkTokenDataFormat");
    }

    public string Protect(MagicLinkToken data)
    {
        var json = Newtonsoft.Json.JsonConvert.SerializeObject(data);
        var bytes = System.Text.Encoding.UTF8.GetBytes(json);
        var protectedTokenBytes = _dataProtector.Protect(bytes);
        return Convert.ToBase64String(protectedTokenBytes);
    }

    public string Protect(MagicLinkToken data, string? purpose)
    {
        throw new NotImplementedException();
    }

    public MagicLinkToken? Unprotect(string? protectedText)
    {
        var protectedTokenBytes = Convert.FromBase64String(protectedText ?? "");
        var bytes = _dataProtector.Unprotect(protectedTokenBytes);
        var json = System.Text.Encoding.UTF8.GetString(bytes);
        return JsonSerializer.Deserialize<MagicLinkToken>(json);
    }

    public MagicLinkToken? Unprotect(string? protectedText, string? purpose)
    {
        throw new NotImplementedException();
    }
}
