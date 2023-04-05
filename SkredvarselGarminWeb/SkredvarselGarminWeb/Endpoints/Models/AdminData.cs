namespace SkredvarselGarminWeb.Endpoints.Models;

public class AdminDataUser
{
    public required string Id { get; set; }
    public required string Name { get; set; }
}

public class AdminData
{
    public required List<AdminDataUser> StaleUsers { get; set; }
    public required int NumUsers { get; set; }
    public required int ActiveAgreements { get; set; }
    public required int UnsubscribedAgreements { get; set; }
    public required int ActiveOrUnsubscribedAgreements { get; set; }
    public required int Watches { get; set; }
}
