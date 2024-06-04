using Refit;

using SkredvarselGarminWeb.VippsApi.Models;

namespace SkredvarselGarminWeb.VippsApi;

public interface IVippsApiClient
{
    [Get("/recurring/v3/agreements")]
    Task<List<Agreement>> GetAgreements([Query] AgreementStatus status = AgreementStatus.Active);

    [Get("/recurring/v3/agreements/{agreementId}")]
    Task<Agreement> GetAgreement([AliasAs("agreementId")] string agreementId);

    [Post("/recurring/v3/agreements")]
    Task<DraftAgreementResponse> CreateAgreement([Body] DraftAgreementRequest request, [Header("Idempotency-Key")] Guid idempotencyKey);

    [Patch("/recurring/v3/agreements/{agreementId}")]
    Task<IApiResponse> PatchAgreement([AliasAs("agreementId")] string agreementId, [Body] PatchAgreementRequest request, [Header("Idempotency-Key")] Guid idempotencyKey);

    [Get("/recurring/v3/agreements/{agreementId}/charges")]
    Task<List<Charge>> GetCharges([AliasAs("agreementId")] string agreementId, [Query] ChargeStatus? status = null);

    [Post("/recurring/v3/agreements/{agreementId}/charges")]
    Task<CreateChargeResponse> CreateCharge([AliasAs("agreementId")] string agreementId, [Body] CreateChargeRequest request, [Header("Idempotency-Key")] Guid idempotencyKey);

    [Get("/recurring/v3/agreements/{agreementId}/charges/{chargeId}")]
    Task<Charge> GetCharge([AliasAs("agreementId")] string agreementId, [AliasAs("chargeId")] string chargeId);

    [Delete("/recurring/v3/agreements/{agreementId}/charges/{chargeId}")]
    Task<IApiResponse> CancelCharge([AliasAs("agreementId")] string agreementId, [AliasAs("chargeId")] string chargeId, [Header("Idempotency-Key")] Guid idempotencyKey);

    [Post("/recurring/v3/agreements/{agreementId}/charges/{chargeId}/capture")]
    Task<IApiResponse> CaptureCharge([AliasAs("agreementId")] string agreementId, [AliasAs("chargeId")] string chargeId, [Body] CaptureChargeRequest request, [Header("Idempotency-Key")] Guid idempotencyKey);

    [Post("/recurring/v3/agreements/{agreementId}/charges/{chargeId}/refund")]
    Task<IApiResponse> RefundCharge([AliasAs("agreementId")] string agreementId, [AliasAs("chargeId")] string chargeId, [Header("Idempotency-Key")] Guid idempotencyKey);

    [Get("/vipps-userinfo-api/userinfo/{sub}")]
    Task<UserInfo> GetUserInfo([AliasAs("sub")] string sub);
}
