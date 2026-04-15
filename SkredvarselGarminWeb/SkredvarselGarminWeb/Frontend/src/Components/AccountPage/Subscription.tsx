import { format, parse } from "date-fns";
import { useTranslation } from "react-i18next";
import {
  useReactivateVippsAgreement,
  useStopVippsAgreement,
  useSubscription,
} from "../../hooks/useSubscription";
import { VippsButton } from "../Buttons/VippsButton";
import { StripeButton } from "../Buttons/StripeButton";
import { Button } from "../ui/button";
import { Separator } from "../ui/separator";
import { Spinner } from "../ui/spinner";

const StripeCustomerPortalButton = () => {
  const { t } = useTranslation();

  return (
    <Button
      nativeButton={false}
      render={(props) => <a {...props} href="/stripe-customer-portal" />}
      variant="blue"
    >
      {t(($) => $.buttons.stripe.manageInStripe)}
    </Button>
  );
};

export const Subscription = () => {
  const { t } = useTranslation();
  const { data: subscription, isLoading: isSubscriptionLoading } =
    useSubscription();

  const stopSubscription = useStopVippsAgreement();
  const reactivateSubscription = useReactivateVippsAgreement();

  if (isSubscriptionLoading) {
    return (
      <div className="flex items-center justify-center">
        <Spinner className="size-5" />
      </div>
    );
  }

  if (!subscription) {
    return (
      <div className="flex flex-col items-start gap-2">
        <p className="mb-2">{t(($) => $.account.subscription.none)}</p>

        <div className="flex flex-col gap-5">
          <VippsButton text={t(($) => $.buttons.vipps.buySubscriptionWith)} />
          <div className="relative">
            <Separator />
            <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-background px-4">
              {t(($) => $.common.or)}
            </div>
          </div>
          <StripeButton />
        </div>
      </div>
    );
  }

  const {
    subscriptionType,
    nextChargeDate,
    stripeSubscriptionStatus,
    vippsAgreementStatus,
    vippsConfirmationUrl,
  } = subscription;

  if (
    subscriptionType === "Vipps" &&
    vippsAgreementStatus === "PENDING" &&
    vippsConfirmationUrl
  ) {
    return (
      <div className="flex flex-col items-start gap-2">
        <p className="mb-2">{t(($) => $.account.subscription.pending)}</p>

        <VippsButton
          className="w-full cursor-pointer"
          text={t(($) => $.buttons.vipps.goTo)}
          link={vippsConfirmationUrl}
        />
      </div>
    );
  }

  var formattedNextChargeDate =
    nextChargeDate != null
      ? format(parse(nextChargeDate, "yyyy-MM-dd", new Date()), "dd.MM.yyyy")
      : null;

  if (subscriptionType === "Vipps" && vippsAgreementStatus == "UNSUBSCRIBED") {
    return (
      <>
        <p className="mb-2">
          {formattedNextChargeDate
            ? t(($) => $.account.subscription.canceled, {
                date: formattedNextChargeDate,
              })
            : t(($) => $.account.subscription.canceled, { date: "" })}
        </p>

        <Button
          variant="green"
          disabled={reactivateSubscription.isPending}
          onClick={() => reactivateSubscription.mutate()}
        >
          {t(($) => $.account.subscription.reactivate)}
        </Button>
      </>
    );
  }

  if (
    subscriptionType === "Stripe" &&
    stripeSubscriptionStatus == "UNSUBSCRIBED"
  ) {
    return (
      <>
        <p className="mb-2">
          {formattedNextChargeDate
            ? t(($) => $.account.subscription.canceled, {
                date: formattedNextChargeDate,
              })
            : t(($) => $.account.subscription.canceled, { date: "" })}
        </p>

        <StripeCustomerPortalButton />
      </>
    );
  }

  return (
    <>
      {subscription != null && (
        <>
          <p className="mb-2">
            {t(($) => $.account.subscription.active)}{" "}
            {formattedNextChargeDate &&
              t(($) => $.account.subscription.renewsOn, {
                date: formattedNextChargeDate,
              })}
          </p>

          {subscriptionType == "Vipps" && (
            <Button
              variant="secondary"
              disabled={stopSubscription.isPending}
              onClick={() => stopSubscription.mutate()}
            >
              {t(($) => $.account.subscription.cancel)}
            </Button>
          )}

          {subscriptionType == "Stripe" && <StripeCustomerPortalButton />}
        </>
      )}
    </>
  );
};
