using AutoFixture;
using Hangfire;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Logging;
using NSubstitute;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.VippsApi;
using VippsAgreement = SkredvarselGarminWeb.VippsApi.Models.Agreement;
using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;
using VippsAgreementCampaign = SkredvarselGarminWeb.VippsApi.Models.AgreementCampaign;
using VippsCampaignType = SkredvarselGarminWeb.VippsApi.Models.CampaignType;
using VippsPeriod = SkredvarselGarminWeb.VippsApi.Models.Period;
using VippsPeriodUnit = SkredvarselGarminWeb.VippsApi.Models.PeriodUnit;
using VippsCharge = SkredvarselGarminWeb.VippsApi.Models.Charge;
using VippsChargeStatus = SkredvarselGarminWeb.VippsApi.Models.ChargeStatus;
using VippsCaptureChargeRequest = SkredvarselGarminWeb.VippsApi.Models.CaptureChargeRequest;
using VippsCreateChargeRequest = SkredvarselGarminWeb.VippsApi.Models.CreateChargeRequest;
using VippsCreateChargeResponse = SkredvarselGarminWeb.VippsApi.Models.CreateChargeResponse;
using VippsPatchAgreementRequest = SkredvarselGarminWeb.VippsApi.Models.PatchAgreementRequest;
using VippsPatchAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.PatchAgreementStatus;
using Refit;
using System.Net;
using SkredvarselGarminWeb.Helpers;
using FluentAssertions;
using SkredvarselGarminWeb.Services;

namespace SkredvarselGarminWeb.Tests;

public class SubscriptionServiceTests
{
    private readonly Fixture _fixture;
    private readonly SkredvarselDbContext _dbContext;
    private readonly IDateTimeNowProvider _dateTimeNowProvider;
    private readonly IVippsApiClient _vippsApiClient;
    private readonly ISubscriptionService _subscriptionService;

    public SubscriptionServiceTests()
    {
        _fixture = new Fixture();
        _fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        _fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var dbContextOptions = new DbContextOptionsBuilder<SkredvarselDbContext>()
            .UseInMemoryDatabase("HangfireServiceTests")
            .ConfigureWarnings(b => b.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .Options;

        _dbContext = new SkredvarselDbContext(dbContextOptions);
        _dbContext.Database.EnsureDeleted();
        _dbContext.Database.EnsureCreated();

        _vippsApiClient = Substitute.For<IVippsApiClient>();
        _dateTimeNowProvider = Substitute.For<IDateTimeNowProvider>();

        _subscriptionService = new SubscriptionService(
            _dbContext,
            _vippsApiClient,
            _dateTimeNowProvider,
            Substitute.For<ILogger<SubscriptionService>>());
    }

    [Fact]
    public async Task Should_claim_and_create_new_charge()
    {
        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNewChargeId = "newChargeId";

        var nextChargeDate = new DateOnly(2023, 4, 13);
        var expectedNextChargeDate = new DateOnly(2023, 5, 13);

        _dateTimeNowProvider.Now.Returns(nextChargeDate.ToDateTime(TimeOnly.MinValue).AddDays(7.0));

        var nextVippsCharge = _fixture.Build<VippsCharge>()
            .With(c => c.Status, VippsChargeStatus.RESERVED)
            .Create();

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.ACTIVE)
            .With(a => a.NextChargeDate, nextChargeDate)
            .With(a => a.NextChargeId, nextVippsCharge.Id)
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .With(a => a.Campaign, new VippsAgreementCampaign
            {
                Type = VippsCampaignType.PeriodCampaign,
                Price = 2000,
                End = new DateTime(2023, 2, 12),
                Period = new VippsPeriod
                {
                    Count = 1,
                    Unit = VippsPeriodUnit.Month
                }
            })
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextVippsCharge.Id).Returns(nextVippsCharge);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.CaptureCharge(agreement.Id, nextVippsCharge.Id, Arg.Any<VippsCaptureChargeRequest>(), Arg.Any<Guid>()).Returns(successResponse);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).CaptureCharge(agreement.Id, nextVippsCharge.Id, Arg.Is<VippsCaptureChargeRequest>(x => x.Amount == nextVippsCharge.Amount), Arg.Any<Guid>());
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Pricing.Amount && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(expectedNextChargeDate);
    }

    [Fact]
    public async Task Should_work_if_nextChargeId_is_null()
    {
        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNewChargeId = "newChargeId";

        _dateTimeNowProvider.Now.Returns(new DateOnly(2023, 4, 13).ToDateTime(TimeOnly.MinValue));
        var expectedNextChargeDate = new DateOnly(2023, 5, 13);

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.ACTIVE)
            .Without(a => a.NextChargeDate)
            .Without(a => a.NextChargeId)
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .With(a => a.Campaign, new VippsAgreementCampaign
            {
                Type = VippsCampaignType.PeriodCampaign,
                Price = 2000,
                End = new DateTime(2023, 2, 12),
                Period = new VippsPeriod
                {
                    Count = 1,
                    Unit = VippsPeriodUnit.Month
                }
            })
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.DidNotReceiveWithAnyArgs().CaptureCharge(default!, default!, default!, default!);
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Pricing.Amount && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(expectedNextChargeDate);
    }

    [Fact]
    public async Task Should_not_do_anything_if_agreement_is_not_due_for_charge()
    {
        var agreementStart = new DateOnly(2023, 2, 13);
        var nextChargeDate = new DateOnly(2023, 2, 25);

        _dateTimeNowProvider.Now.Returns(new DateOnly(2023, 2, 20).ToDateTime(TimeOnly.MinValue));

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.ACTIVE)
            .With(a => a.NextChargeDate, nextChargeDate)
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.DidNotReceiveWithAnyArgs().GetAgreement(default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().GetCharge(default!, default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().CaptureCharge(default!, default!, default!, default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().CreateCharge(default!, default!, default!);
    }

    [Fact]
    public async Task Should_use_normal_price_and_date_at_end_of_campaign_if_inside_period_campaign()
    {
        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNewChargeId = "newChargeId";
        var expectedNextChargeDate = agreementStart.AddDays(7);

        _dateTimeNowProvider.Now.Returns(agreementStart.ToDateTime(TimeOnly.MaxValue));

        var nextVippsCharge = _fixture.Build<VippsCharge>()
            .With(c => c.Status, VippsChargeStatus.RESERVED)
            .Create();

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.ACTIVE)
            .With(a => a.NextChargeDate, agreementStart)
            .With(a => a.NextChargeId, nextVippsCharge.Id)
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .With(a => a.Campaign, new VippsAgreementCampaign
            {
                Type = VippsCampaignType.PeriodCampaign,
                Price = 1000,
                Period = new VippsPeriod
                {
                    Count = 1,
                    Unit = VippsPeriodUnit.Week
                }
            })
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextVippsCharge.Id).Returns(nextVippsCharge);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.CaptureCharge(agreement.Id, nextVippsCharge.Id, Arg.Any<VippsCaptureChargeRequest>(), Arg.Any<Guid>()).Returns(successResponse);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).CaptureCharge(agreement.Id, nextVippsCharge.Id, Arg.Is<VippsCaptureChargeRequest>(x => x.Amount == nextVippsCharge.Amount), Arg.Any<Guid>());
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Pricing.Amount && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(expectedNextChargeDate);
    }

    [Fact]
    public async Task Should_use_campaign_price_and_normal_interval_if_inside_price_campaign()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNewChargeId = "newChargeId";
        var expectedNextChargeDate = agreementStart.AddDays(7);

        _dateTimeNowProvider.Now.Returns(agreementStart.ToDateTime(TimeOnly.MaxValue).AddDays(1));

        var nextVippsCharge = _fixture.Build<VippsCharge>()
            .With(c => c.Status, VippsChargeStatus.RESERVED)
            .Create();

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.ACTIVE)
            .With(a => a.NextChargeDate, agreementStart)
            .With(a => a.NextChargeId, nextVippsCharge.Id)
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .With(a => a.Campaign, new VippsAgreementCampaign
            {
                Price = 1000,
                Type = VippsCampaignType.PriceCampaign,
                End = agreementStart.AddMonths(1).ToDateTime(TimeOnly.MinValue)
            })
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Week
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextVippsCharge.Id).Returns(nextVippsCharge);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.CaptureCharge(agreement.Id, nextVippsCharge.Id, Arg.Any<VippsCaptureChargeRequest>(), Arg.Any<Guid>()).Returns(successResponse);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).CaptureCharge(agreement.Id, nextVippsCharge.Id, Arg.Is<VippsCaptureChargeRequest>(x => x.Amount == nextVippsCharge.Amount), Arg.Any<Guid>());
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Campaign!.Price && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(expectedNextChargeDate);
    }

    [Fact]
    public async Task Should_use_normal_price_and_normal_interval_if_outside_price_campaign()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNewChargeId = "newChargeId";
        var expectedNextChargeDate = new DateOnly(2023, 3, 20);

        _dateTimeNowProvider.Now.Returns(new DateOnly(2023, 3, 14).ToDateTime(TimeOnly.MinValue));

        var nextVippsCharge = _fixture.Build<VippsCharge>()
            .With(c => c.Status, VippsChargeStatus.RESERVED)
            .Create();

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.ACTIVE)
            .With(a => a.NextChargeDate, agreementStart)
            .With(a => a.NextChargeId, nextVippsCharge.Id)
            .With(a => a.NextChargeDate, new DateOnly(2023, 3, 13))
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .With(a => a.Campaign, new VippsAgreementCampaign
            {
                Price = 1000,
                Type = VippsCampaignType.PriceCampaign,
                End = agreementStart.AddMonths(1).ToDateTime(TimeOnly.MinValue)
            })
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Week
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextVippsCharge.Id).Returns(nextVippsCharge);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.CaptureCharge(agreement.Id, nextVippsCharge.Id, Arg.Any<VippsCaptureChargeRequest>(), Arg.Any<Guid>()).Returns(successResponse);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).CaptureCharge(agreement.Id, nextVippsCharge.Id, Arg.Is<VippsCaptureChargeRequest>(x => x.Amount == nextVippsCharge.Amount), Arg.Any<Guid>());
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Pricing.Amount && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(expectedNextChargeDate);
    }

    [Fact]
    public async Task Should_not_try_to_capture_if_charge_is_already_charged()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);

        var expectedNewChargeId = "newChargeId";

        var nextChargeDate = new DateOnly(2023, 3, 13);
        var expectedNextChargeDate = nextChargeDate.AddMonths(1);

        _dateTimeNowProvider.Now.Returns(nextChargeDate.ToDateTime(TimeOnly.MinValue));

        var nextVippsCharge = _fixture.Build<VippsCharge>()
            .With(c => c.Status, VippsChargeStatus.CHARGED)
            .Create();

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.ACTIVE)
            .With(a => a.NextChargeDate, new DateOnly(2023, 3, 13))
            .With(a => a.NextChargeId, nextVippsCharge.Id)
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .With(a => a.Campaign, new VippsAgreementCampaign
            {
                Type = VippsCampaignType.PeriodCampaign,
                Price = 1000,
                Period = new VippsPeriod
                {
                    Count = 1,
                    Unit = VippsPeriodUnit.Week
                }
            })
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextVippsCharge.Id).Returns(nextVippsCharge);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.DidNotReceiveWithAnyArgs().CaptureCharge(default!, default!, default!, default!);
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Pricing.Amount && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(expectedNextChargeDate);
    }

    [Fact]
    public async Task Should_not_stop_agreements_in_vipps_that_are_unsubscribed_and_date_is_earlier_than_nextChargeDate()
    {
        var nextChargeDate = new DateOnly(2023, 4, 13);

        _dateTimeNowProvider.Now.Returns(nextChargeDate.ToDateTime(TimeOnly.MinValue).AddDays(-1));

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Status, AgreementStatus.UNSUBSCRIBED)
            .With(a => a.NextChargeDate, nextChargeDate)
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.PatchAgreement(default!, default!, default!).ReturnsForAnyArgs(successResponse);

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.DidNotReceiveWithAnyArgs().PatchAgreement(default!, default!, default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().CaptureCharge(default!, default!, default!, default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().CreateCharge(default!, default!, default!);

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.Status.Should().Be(AgreementStatus.UNSUBSCRIBED);
        updatedAgreementInDb.NextChargeDate.Should().NotBeNull();
    }

    [Fact]
    public async Task Should_stop_agreements_in_vipps_that_are_unsubscribed_and_date_is_later_than_nextChargeDate()
    {
        var nextChargeDate = new DateOnly(2023, 4, 13);

        _dateTimeNowProvider.Now.Returns(nextChargeDate.ToDateTime(TimeOnly.MinValue).AddDays(1));

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Status, AgreementStatus.UNSUBSCRIBED)
            .With(a => a.NextChargeDate, nextChargeDate)
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.PatchAgreement(default!, default!, default!).ReturnsForAnyArgs(successResponse);

        await _subscriptionService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).PatchAgreement(agreement.Id, Arg.Is<VippsPatchAgreementRequest>(r => r.Status == VippsPatchAgreementStatus.Stopped), Arg.Any<Guid>());
        await _vippsApiClient.DidNotReceiveWithAnyArgs().CaptureCharge(default!, default!, default!, default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().CreateCharge(default!, default!, default!);

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.Status.Should().Be(AgreementStatus.STOPPED);
        updatedAgreementInDb.NextChargeId.Should().BeNull();
        updatedAgreementInDb.NextChargeDate.Should().BeNull();
    }

    [Fact]
    public async Task Should_calculate_reactivation_price_and_date_correctly_when_reactivating_an_agreement_without_campagin()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNewChargeId = "newChargeId";

        _dateTimeNowProvider.Now.Returns(agreementStart.ToDateTime(TimeOnly.MaxValue).AddDays(3));

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.UNSUBSCRIBED)
            .With(a => a.NextChargeDate, new DateOnly(2023, 3, 13))
            .Without(a => a.NextChargeId)
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .Without(a => a.Campaign)
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.ReactivateAgreement(agreement.Id);

        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Pricing.Amount && x.Due == agreement.NextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(agreement.NextChargeDate);
    }

    [Fact]
    public async Task Should_calculate_reactivation_price_and_date_correctly_when_reactivating_an_agreement_with_period_campagin()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNextChargeDate = new DateOnly(2023, 2, 20);
        var expectedNewChargeId = "newChargeId";

        _dateTimeNowProvider.Now.Returns(agreementStart.ToDateTime(TimeOnly.MaxValue).AddDays(3));

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.UNSUBSCRIBED)
            .With(a => a.NextChargeDate, new DateOnly(2023, 3, 13))
            .Without(a => a.NextChargeId)
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .With(a => a.Campaign, new VippsAgreementCampaign
            {
                Type = VippsCampaignType.PeriodCampaign,
                Price = 1000,
                Period = new VippsPeriod
                {
                    Count = 1,
                    Unit = VippsPeriodUnit.Week
                }
            })
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.ReactivateAgreement(agreement.Id);

        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Pricing.Amount && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(agreement.NextChargeDate);
    }

    [Fact]
    public async Task Should_calculate_reactivation_price_and_date_correctly_when_reactivating_an_agreement_with_price_campagin()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNextChargeDate = new DateOnly(2023, 3, 13);
        var expectedNewChargeId = "newChargeId";

        _dateTimeNowProvider.Now.Returns(agreementStart.ToDateTime(TimeOnly.MaxValue).AddDays(3));

        var agreement = _fixture.Build<Agreement>()
            .With(a => a.Start, agreementStart)
            .With(a => a.Status, AgreementStatus.UNSUBSCRIBED)
            .With(a => a.NextChargeDate, new DateOnly(2023, 3, 13))
            .Without(a => a.NextChargeId)
            .Create();

        var vippsAgreement = _fixture.Build<VippsAgreement>()
            .With(a => a.Start, agreementStart.ToDateTime(TimeOnly.MinValue))
            .With(a => a.Status, VippsAgreementStatus.Active)
            .With(a => a.Campaign, new VippsAgreementCampaign
            {
                Price = 1000,
                Type = VippsCampaignType.PriceCampaign,
                End = agreementStart.AddMonths(1).ToDateTime(TimeOnly.MinValue)
            })
            .With(a => a.Interval, new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            })
            .Create();

        _dbContext.Add(agreement);
        _dbContext.SaveChanges();

        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _subscriptionService.ReactivateAgreement(agreement.Id);

        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == vippsAgreement.Campaign!.Price && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(agreement.NextChargeDate);
    }
}
