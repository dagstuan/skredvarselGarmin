using System.Security.Claims;

using Hangfire;

using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;

using Refit;

using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities.Extensions;
using SkredvarselGarminWeb.Extensions;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.Services;
using SkredvarselGarminWeb.VippsApi;
using SkredvarselGarminWeb.VippsApi.Models;

using AgreementStatus = SkredvarselGarminWeb.Entities.AgreementStatus;
using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;

namespace SkredvarselGarminWeb.Endpoints;

public static class VippsSubscriptionEndpointsRouteBuilderExtensions
{
    private const int FullPrice = 3000;

    private static async Task<Agreement> GetVippsAgreementRetryIfPending(IVippsApiClient vippsApiClient, string agreementId)
    {
        var retries = 0;
        var vippsAgreement = await vippsApiClient.GetAgreement(agreementId);

        while (vippsAgreement.Status == VippsAgreementStatus.Pending && retries < 5)
        {
            retries++;

            await Task.Delay(750);

            vippsAgreement = await vippsApiClient.GetAgreement(agreementId);
        }

        return vippsAgreement;
    }

    private static async Task StopOldAgreementsForUser(
        Entities.User user,
        SkredvarselDbContext dbContext,
        IVippsAgreementService subscriptionService)
    {
        var existingActiveAgreementsForUser = dbContext.Agreements
            .Where(a => a.UserId == user.Id)
            .Where(a => a.Status == AgreementStatus.ACTIVE)
            .Select(a => a.Id)
            .ToList();

        foreach (var existingAgreement in existingActiveAgreementsForUser)
        {
            await subscriptionService.StopAgreement(existingAgreement);
        }
    }

    private static ClaimsPrincipal GetVippsAgreementPrincipal(string userId, UserInfo userInfo)
    {
        return new ClaimsPrincipal(new ClaimsIdentity(
        [
            new("name", userInfo.Name),
            new("email", userInfo.Email),
            new("sub", userId),
        ], CookieAuthenticationDefaults.AuthenticationScheme));
    }

    public static void MapVippsSubscriptionEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/createVippsAgreement", async (
            [FromQuery]
            string? watchKey,
            HttpContext ctx,
            IVippsApiClient vippsApiClient,
            IUserService userService,
            SkredvarselDbContext dbContext,
            IDateTimeNowProvider dateTimeNowProvider) =>
        {
            var baseUrl = ctx.GetBaseUrl();
            string? userId = null;

            var callbackId = Guid.NewGuid();

            if (ctx.User.Identity?.IsAuthenticated ?? false)
            {
                var user = userService.GetUserOrThrow(ctx.User);

                userId = user.Id;

                var existingAgreementsForUser = dbContext.Agreements
                    .Where(a => a.UserId == userId)
                    .ToList();

                if (existingAgreementsForUser.Any(x => x.Status == AgreementStatus.ACTIVE))
                {
                    return Results.Redirect($"{baseUrl}/account");
                }

                var pendingAgreementForUser = existingAgreementsForUser.FirstOrDefault(x => x.Status == AgreementStatus.PENDING);
                if (pendingAgreementForUser != null && pendingAgreementForUser.ConfirmationUrl != null)
                {
                    return Results.Redirect(pendingAgreementForUser.ConfirmationUrl);
                }
            }

            var request = new DraftAgreementRequest
            {
                Pricing = new()
                {
                    Amount = FullPrice,
                },
                Interval = new()
                {
                    Count = 1,
                    Unit = PeriodUnit.Year
                },
                InitialCharge = new()
                {
                    Amount = FullPrice,
                    Description = "Skredvarsel for Garmin"
                },
                ProductName = "Skredvarsel for Garmin",
                MerchantAgreementUrl = $"{baseUrl}/account",
                MerchantRedirectUrl = $"{baseUrl}/vipps-subscribe-callback?callbackId={callbackId}",
                Scope = "name email"
            };

            try
            {
                var createdAgreement = await vippsApiClient.CreateAgreement(request, Guid.NewGuid());

                dbContext.Add(new Entities.Agreement
                {
                    Id = createdAgreement.AgreementId,
                    CallbackId = callbackId,
                    WatchKey = watchKey,
                    Created = dateTimeNowProvider.Now.ToUniversalTime(),
                    UserId = userId,
                    Status = AgreementStatus.PENDING,
                    ConfirmationUrl = createdAgreement.VippsConfirmationUrl,
                    Start = DateOnly.FromDateTime(DateTime.Now),
                    NextChargeId = createdAgreement.ChargeId,
                    NextChargeDate = DateOnly.FromDateTime(DateTime.Now)
                });
                dbContext.SaveChanges();

                return Results.Redirect(createdAgreement.VippsConfirmationUrl);
            }
            catch (ValidationApiException e)
            {
                return Results.BadRequest(e.Content);
            }
        }).AllowAnonymous();

        app.MapGet("/vipps-subscribe-callback", async (
            [FromQuery]
            [BindRequired]
            Guid callbackId,
            HttpContext ctx,
            SkredvarselDbContext dbContext,
            IVippsApiClient vippsApiClient,
            IVippsAgreementService subscriptionService,
            IUserService userService,
            IWatchService watchService,
            INotificationService notificationService,
            IBackgroundJobClient backgroundJobClient,
            IDateTimeNowProvider dateTimeNowProvider,
            ILoggerFactory loggerFactory) =>
        {
            var logger = loggerFactory.CreateLogger("vipps-subscribe-callback");

            using var transaction = dbContext.Database.BeginTransaction();

            var agreement = dbContext.GetAgreementWithCallbackId(callbackId);

            if (agreement != null)
            {
                var vippsAgreement = await GetVippsAgreementRetryIfPending(vippsApiClient, agreement.Id);
                if (vippsAgreement.Status is
                    VippsAgreementStatus.Stopped or
                    VippsAgreementStatus.Expired)
                {
                    logger.LogInformation("Agreement {agreementId} was stopped or expired in Vipps. Deleting.", agreement.Id);
                    dbContext.Remove(agreement);
                }
                else if (vippsAgreement.Status == VippsAgreementStatus.Active)
                {
                    try
                    {
                        if (string.IsNullOrEmpty(agreement.UserId))
                        {
                            var signedInUser = dbContext.GetUserOrNull(ctx.User);
                            if (signedInUser != null)
                            {
                                // User is already signed in. Associate agreement with logged in user instead of vipps-sub.
                                agreement.SetUserId(signedInUser.Id);
                            }
                            else
                            {
                                // User is not already signed in. First attempt to find and existing user with the
                                // same sub, and if found, stop all active agreements for that user. Then login using
                                // the sub from the vipps agreement.
                                var userId = vippsAgreement.Sub;

                                var existingUser = dbContext.Users.FirstOrDefault(u => u.Id == vippsAgreement.Sub);
                                var userInfo = await vippsApiClient.GetUserInfo(userId);

                                // Couldn't find user by sup. Attempt to find user by email.
                                existingUser ??= dbContext.Users.FirstOrDefault(u => u.Email == userInfo.Email);

                                if (existingUser != null)
                                {
                                    try
                                    {
                                        await StopOldAgreementsForUser(existingUser, dbContext, subscriptionService);
                                    }
                                    catch (Exception e)
                                    {
                                        logger.LogError(e, "Failed to stop old agreements for user {userId}.", existingUser.Id);
                                        _ = Task.Run(notificationService.NotifyActivationFailed);
                                    }
                                }

                                agreement.SetUserId(userId);

                                var principal = GetVippsAgreementPrincipal(userId, userInfo);
                                await ctx.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal);
                                userService.RegisterLogin(principal);
                            }
                        }

                        if (string.IsNullOrEmpty(agreement.UserId))
                        {
                            // This should not be possible at this stage.
                            throw new Exception("Failed to associate agreement with user.");
                        }

                        if (agreement.WatchKey != null)
                        {
                            var watchAddRequest = watchService.GetWatchAddRequest(agreement.WatchKey);

                            if (watchAddRequest != null)
                            {
                                watchService.AddWatch(watchAddRequest, agreement.UserId);
                            }
                            else
                            {
                                logger.LogWarning("Failed to find watch add request with key {watchKey}.", agreement.WatchKey);
                            }
                        }

                        _ = Task.Run(notificationService.NotifyUserSubscribed);

                        agreement.SetAsActive();
                        agreement.RemoveCallbackIdAndWatchKey();

                        try
                        {
                            await subscriptionService.UpdateAgreementCharges(agreement.Id);
                        }
                        catch (Exception e)
                        {
                            logger.LogError(e, "Failed to update agreement charges for agreement {agreementId}. Retrying via Hangfire.", agreement.Id);
                            backgroundJobClient.Enqueue(() => subscriptionService.UpdateAgreementCharges(agreement.Id));
                        }
                    }
                    catch (Exception e)
                    {
                        logger.LogError(e, "Failed to activate agreement {agreementId}.", agreement.Id);
                        _ = Task.Run(notificationService.NotifyActivationFailed);
                    }
                }
                else if (vippsAgreement.Status == VippsAgreementStatus.Pending)
                {
                    logger.LogInformation("Subscription was still pending after 5 retries. Returning.");
                    await notificationService.NotifyActivationFailed();
                }
            }

            dbContext.SaveChanges();

            transaction.Commit();

            return Results.Redirect("/account");
        }).AllowAnonymous();

        app.MapDelete("/api/vippsAgreement", async (
            HttpContext ctx,
            IVippsAgreementService subscriptionService,
            INotificationService notificationService,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User);

            var agreementInDb = dbContext.Agreements
                .Where(a => a.Status == AgreementStatus.ACTIVE)
                .FirstOrDefault(a => a.UserId == user.Id);

            if (agreementInDb == null)
            {
                return Results.BadRequest("No subscription found.");
            }

            await subscriptionService.DeactivateAgreement(agreementInDb.Id);

            _ = Task.Run(notificationService.NotifyUserDeactivated);

            return Results.Ok();

        }).RequireAuthorization();

        app.MapPut("/api/vippsAgreement/reactivate", async (
            HttpContext ctx,
            IVippsAgreementService subscriptionService,
            INotificationService notificationService,
            SkredvarselDbContext dbContext) =>
        {
            var user = dbContext.GetUserOrThrow(ctx.User);

            var agreementInDb = dbContext.Agreements
                .Where(a => a.Status == AgreementStatus.UNSUBSCRIBED)
                .FirstOrDefault(a => a.UserId == user.Id);

            if (agreementInDb == null)
            {
                return Results.BadRequest("No subscription found.");
            }

            await subscriptionService.ReactivateAgreement(agreementInDb.Id);

            _ = Task.Run(notificationService.NotifyUserReactivated);

            return Results.Ok();
        }).RequireAuthorization();
    }
}
