using Microsoft.AspNetCore.Authentication;

namespace SkredvarselGarminWeb.MagicLink;

public interface IMagicLinkTokenDataFormat : ISecureDataFormat<MagicLinkToken>
{

}
