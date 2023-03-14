using AutoFixture;
using Hangfire;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Logging;
using NSubstitute;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Hangfire;
using SkredvarselGarminWeb.VippsApi;
using VippsAgreement = SkredvarselGarminWeb.VippsApi.Models.Agreement;
using VippsAgreementStatus = SkredvarselGarminWeb.VippsApi.Models.AgreementStatus;
using VippsAgreementCampaign = SkredvarselGarminWeb.VippsApi.Models.AgreementCampaign;
using VippsPeriod = SkredvarselGarminWeb.VippsApi.Models.Period;
using VippsPeriodUnit = SkredvarselGarminWeb.VippsApi.Models.PeriodUnit;
using VippsPricing = SkredvarselGarminWeb.VippsApi.Models.Pricing;
using VippsCharge = SkredvarselGarminWeb.VippsApi.Models.Charge;
using VippsChargeStatus = SkredvarselGarminWeb.VippsApi.Models.ChargeStatus;
using VippsCaptureChargeRequest = SkredvarselGarminWeb.VippsApi.Models.CaptureChargeRequest;
using VippsCreateChargeRequest = SkredvarselGarminWeb.VippsApi.Models.CreateChargeRequest;
using VippsCreateChargeResponse = SkredvarselGarminWeb.VippsApi.Models.CreateChargeResponse;
using Refit;
using System.Net;
using SkredvarselGarminWeb.Helpers;
using FluentAssertions;

namespace SkredvarselGarminWeb.Tests;

public class HangfireServiceTests
{
    private readonly HangfireService _hangfireService;
    private readonly SkredvarselDbContext _dbContext;
    private readonly IDateTimeNowProvider _dateTimeNowProvider;
    private readonly IVippsApiClient _vippsApiClient;

    public HangfireServiceTests()
    {
        var dbContextOptions = new DbContextOptionsBuilder<SkredvarselDbContext>()
            .UseInMemoryDatabase("HangfireServiceTests")
            .ConfigureWarnings(b => b.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .Options;

        _dbContext = new SkredvarselDbContext(dbContextOptions);
        _dbContext.Database.EnsureDeleted();
        _dbContext.Database.EnsureCreated();

        _vippsApiClient = Substitute.For<IVippsApiClient>();
        _dateTimeNowProvider = Substitute.For<IDateTimeNowProvider>();

        _hangfireService = new HangfireService(
            _dbContext,
            _vippsApiClient,
            Substitute.For<IBackgroundJobClient>(),
            _dateTimeNowProvider,
            Substitute.For<ILogger<HangfireService>>());
    }

    [Fact]
    public async Task Should_claim_and_create_new_charge()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNewChargeId = "newChargeId";

        var nextChargeDate = new DateOnly(2023, 4, 13);
        var nextChargeId = "nextChargeId";
        var expectedNextChargeDate = new DateOnly(2023, 5, 13);

        _dateTimeNowProvider.Now.Returns(nextChargeDate.ToDateTime(TimeOnly.MinValue));

        var agreement = new Agreement
        {
            Id = "foo",
            Start = agreementStart,
            Status = AgreementStatus.ACTIVE,
            NextChargeDate = nextChargeDate,
            NextChargeId = nextChargeId
        };

        var vippsAgreement = new VippsAgreement
        {
            Id = "foo",
            Status = VippsAgreementStatus.Active,
            Start = agreementStart.ToDateTime(TimeOnly.MinValue),
            Campaign = new VippsAgreementCampaign
            {
                End = new DateTime(2023, 2, 12),
                Period = new VippsPeriod
                {
                    Count = 1,
                    Unit = VippsPeriodUnit.Month
                }
            },
            Interval = new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            },
            Pricing = new VippsPricing
            {
                Amount = 30000
            }
        };

        var nextVippsCharge = new VippsCharge
        {
            Id = nextChargeId,
            Amount = 1000,
            Status = VippsChargeStatus.RESERVED
        };

        var user = fixture.Build<User>()
            .With(x => x.Agreement, agreement)
            .Create();

        _dbContext.Add(user);
        _dbContext.SaveChanges();

        var userFromDb = _dbContext.Users.FirstOrDefault(u => u.Id == user.Id);
        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextChargeId).Returns(nextVippsCharge);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.CaptureCharge(agreement.Id, nextChargeId, Arg.Any<VippsCaptureChargeRequest>(), Arg.Any<Guid>()).Returns(successResponse);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _hangfireService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).CaptureCharge(agreement.Id, nextChargeId, Arg.Is<VippsCaptureChargeRequest>(x => x.Amount == 1000), Arg.Any<Guid>());
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == 30000 && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(expectedNextChargeDate);
    }

    [Fact]
    public async Task Should_not_do_anything_if_agreement_is_not_due_for_charge()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);
        var nextChargeDate = new DateOnly(2023, 2, 25);

        _dateTimeNowProvider.Now.Returns(new DateOnly(2023, 2, 20).ToDateTime(TimeOnly.MinValue));

        var nextChargeId = "nextChargeId";

        var agreement = new Agreement
        {
            Id = "foo",
            Start = agreementStart,
            Status = AgreementStatus.ACTIVE,
            NextChargeDate = nextChargeDate,
            NextChargeId = nextChargeId
        };

        var user = fixture.Build<User>()
            .With(x => x.Agreement, agreement)
            .Create();

        _dbContext.Add(user);
        _dbContext.SaveChanges();

        await _hangfireService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.DidNotReceiveWithAnyArgs().GetAgreement(default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().GetCharge(default!, default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().CaptureCharge(default!, default!, default!, default!);
        await _vippsApiClient.DidNotReceiveWithAnyArgs().CreateCharge(default!, default!, default!);
    }

    [Fact]
    public async Task Should_use_normal_price_and_date_at_end_of_campaign_if_inside_period_campaign()
    {
        var fixture = new Fixture();
        fixture.Customize<DateOnly>(composer => composer.FromFactory<DateTime>(DateOnly.FromDateTime));
        fixture.Behaviors.Add(new OmitOnRecursionBehavior());

        var agreementStart = new DateOnly(2023, 2, 13);
        var expectedNewChargeId = "newChargeId";
        var expectedNextChargeDate = agreementStart.AddDays(7);

        _dateTimeNowProvider.Now.Returns(agreementStart.ToDateTime(TimeOnly.MaxValue));

        var nextChargeId = "nextChargeId";

        var agreement = new Agreement
        {
            Id = "foo",
            Start = agreementStart,
            Status = AgreementStatus.ACTIVE,
            NextChargeDate = agreementStart,
            NextChargeId = nextChargeId
        };

        var vippsAgreement = new VippsAgreement
        {
            Id = "foo",
            Status = VippsAgreementStatus.Active,
            Start = agreementStart.ToDateTime(TimeOnly.MinValue),
            Campaign = new VippsAgreementCampaign
            {
                Price = 1000,
                Period = new VippsPeriod
                {
                    Count = 1,
                    Unit = VippsPeriodUnit.Week
                }
            },
            Interval = new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            },
            Pricing = new VippsPricing
            {
                Amount = 30000
            }
        };

        var nextVippsCharge = new VippsCharge
        {
            Id = nextChargeId,
            Amount = 1000,
            Status = VippsChargeStatus.RESERVED
        };

        var user = fixture.Build<User>()
            .With(x => x.Agreement, agreement)
            .Create();

        _dbContext.Add(user);
        _dbContext.SaveChanges();

        var userFromDb = _dbContext.Users.FirstOrDefault(u => u.Id == user.Id);
        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextChargeId).Returns(nextVippsCharge);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.CaptureCharge(agreement.Id, nextChargeId, Arg.Any<VippsCaptureChargeRequest>(), Arg.Any<Guid>()).Returns(successResponse);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _hangfireService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).CaptureCharge(agreement.Id, nextChargeId, Arg.Is<VippsCaptureChargeRequest>(x => x.Amount == 1000), Arg.Any<Guid>());
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == 30000 && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

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

        _dateTimeNowProvider.Now.Returns(agreementStart.ToDateTime(TimeOnly.MaxValue));

        var nextChargeId = "nextChargeId";

        var agreement = new Agreement
        {
            Id = "foo",
            Start = agreementStart,
            Status = AgreementStatus.ACTIVE,
            NextChargeDate = agreementStart,
            NextChargeId = nextChargeId
        };

        var vippsAgreement = new VippsAgreement
        {
            Id = "foo",
            Status = VippsAgreementStatus.Active,
            Start = agreementStart.ToDateTime(TimeOnly.MinValue),
            Campaign = new VippsAgreementCampaign
            {
                Price = 1000,
                Type = VippsApi.Models.CampaignType.PriceCampaign,
                End = agreementStart.AddMonths(1).ToDateTime(TimeOnly.MinValue)
            },
            Interval = new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Week
            },
            Pricing = new VippsPricing
            {
                Amount = 30000
            }
        };

        var nextVippsCharge = new VippsCharge
        {
            Id = nextChargeId,
            Amount = 1000,
            Status = VippsChargeStatus.RESERVED
        };

        var user = fixture.Build<User>()
            .With(x => x.Agreement, agreement)
            .Create();

        _dbContext.Add(user);
        _dbContext.SaveChanges();

        var userFromDb = _dbContext.Users.FirstOrDefault(u => u.Id == user.Id);
        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextChargeId).Returns(nextVippsCharge);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.CaptureCharge(agreement.Id, nextChargeId, Arg.Any<VippsCaptureChargeRequest>(), Arg.Any<Guid>()).Returns(successResponse);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _hangfireService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).CaptureCharge(agreement.Id, nextChargeId, Arg.Is<VippsCaptureChargeRequest>(x => x.Amount == 1000), Arg.Any<Guid>());
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == 1000 && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

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

        _dateTimeNowProvider.Now.Returns(new DateOnly(2023, 3, 13).ToDateTime(TimeOnly.MinValue));

        var nextChargeId = "nextChargeId";

        var agreement = new Agreement
        {
            Id = "foo",
            Start = agreementStart,
            Status = AgreementStatus.ACTIVE,
            NextChargeDate = agreementStart,
            NextChargeId = nextChargeId
        };

        var vippsAgreement = new VippsAgreement
        {
            Id = "foo",
            Status = VippsAgreementStatus.Active,
            Start = agreementStart.ToDateTime(TimeOnly.MinValue),
            Campaign = new VippsAgreementCampaign
            {
                Price = 1000,
                Type = VippsApi.Models.CampaignType.PriceCampaign,
                End = agreementStart.AddMonths(1).ToDateTime(TimeOnly.MinValue)
            },
            Interval = new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Week
            },
            Pricing = new VippsPricing
            {
                Amount = 30000
            }
        };

        var nextVippsCharge = new VippsCharge
        {
            Id = nextChargeId,
            Amount = 1000,
            Status = VippsChargeStatus.RESERVED
        };

        var user = fixture.Build<User>()
            .With(x => x.Agreement, agreement)
            .Create();

        _dbContext.Add(user);
        _dbContext.SaveChanges();

        var userFromDb = _dbContext.Users.FirstOrDefault(u => u.Id == user.Id);
        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextChargeId).Returns(nextVippsCharge);

        var successResponse = Substitute.For<IApiResponse>();
        successResponse.StatusCode.Returns(HttpStatusCode.OK);
        successResponse.IsSuccessStatusCode.Returns(true);
        _vippsApiClient.CaptureCharge(agreement.Id, nextChargeId, Arg.Any<VippsCaptureChargeRequest>(), Arg.Any<Guid>()).Returns(successResponse);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _hangfireService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.Received(1).CaptureCharge(agreement.Id, nextChargeId, Arg.Is<VippsCaptureChargeRequest>(x => x.Amount == 1000), Arg.Any<Guid>());
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == 30000 && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

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
        var nextChargeId = "nextChargeId";
        var expectedNextChargeDate = nextChargeDate.AddMonths(1);

        _dateTimeNowProvider.Now.Returns(nextChargeDate.ToDateTime(TimeOnly.MinValue));

        var agreement = new Agreement
        {
            Id = "foo",
            Start = agreementStart,
            Status = AgreementStatus.ACTIVE,
            NextChargeDate = new DateOnly(2023, 3, 13),
            NextChargeId = nextChargeId
        };

        var vippsAgreement = new VippsAgreement
        {
            Id = "foo",
            Status = VippsAgreementStatus.Active,
            Start = agreementStart.ToDateTime(TimeOnly.MinValue),
            Campaign = new VippsAgreementCampaign
            {
                Price = 1000,
                Period = new VippsPeriod
                {
                    Count = 1,
                    Unit = VippsPeriodUnit.Week
                }
            },
            Interval = new VippsPeriod
            {
                Count = 1,
                Unit = VippsPeriodUnit.Month
            },
            Pricing = new VippsPricing
            {
                Amount = 30000
            }
        };

        var nextVippsCharge = new VippsCharge
        {
            Id = nextChargeId,
            Amount = 1000,
            Status = VippsChargeStatus.CHARGED
        };

        var user = fixture.Build<User>()
            .With(x => x.Agreement, agreement)
            .Create();

        _dbContext.Add(user);
        _dbContext.SaveChanges();

        var userFromDb = _dbContext.Users.FirstOrDefault(u => u.Id == user.Id);
        var agreementFromDb = _dbContext.Agreements.First();

        _vippsApiClient.GetAgreement(agreement.Id).Returns(vippsAgreement);
        _vippsApiClient.GetCharge(agreement.Id, nextChargeId).Returns(nextVippsCharge);

        _vippsApiClient.CreateCharge(agreement.Id, Arg.Any<VippsCreateChargeRequest>(), Arg.Any<Guid>()).Returns(new VippsCreateChargeResponse
        {
            ChargeId = expectedNewChargeId
        });

        await _hangfireService.UpdateAgreementCharges(agreement.Id);

        await _vippsApiClient.DidNotReceiveWithAnyArgs().CaptureCharge(default!, default!, default!, default!);
        await _vippsApiClient.Received(1).CreateCharge(agreement.Id, Arg.Is<VippsCreateChargeRequest>(x => x.Amount == 30000 && x.Due == expectedNextChargeDate), Arg.Any<Guid>());

        var updatedAgreementInDb = _dbContext.Agreements.Single(a => a.Id == agreement.Id);
        updatedAgreementInDb.NextChargeId.Should().Be(expectedNewChargeId);
        updatedAgreementInDb.NextChargeDate.Should().Be(expectedNextChargeDate);
    }
}
