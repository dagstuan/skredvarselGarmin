import { format, parse } from "date-fns";
import {
  useReactivateVippsAgreement,
  useStopVippsAgreement,
  useSubscription,
} from "../../hooks/useSubscription";
import { VippsButton } from "../Buttons/VippsButton";
import { StripeButton } from "../Buttons/StripeButton";
import { Button } from "../ui/button";
import { Separator } from "../ui/separator";

const StripeCustomerPortalButton = () => (
  <Button
    render={(props) => <a {...props} href="/stripe-customer-portal" />}
    variant="blue"
    className="rounded"
  >
    Gå til Stripe for å endre abonnement
  </Button>
);

export const Subscription = () => {
  const { data: subscription, isLoading: isSubscriptionLoading } =
    useSubscription();

  const stopSubscription = useStopVippsAgreement();
  const reactivateSubscription = useReactivateVippsAgreement();

  if (isSubscriptionLoading) {
    return (
      <div className="flex items-center justify-center">
        <svg
          className="animate-spin h-5 w-5"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          ></circle>
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          ></path>
        </svg>
      </div>
    );
  }

  if (!subscription) {
    return (
      <div className="flex flex-col items-start gap-2">
        <p className="mb-2">Du har ikke registrert et abonnement på appen.</p>

        <div className="flex flex-col gap-5 w-full">
          <VippsButton text="Kjøp abonnement med" />
          <div className="relative">
            <Separator />
            <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-background px-4">
              Eller
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

  if (subscriptionType === "Vipps") {
    if (vippsAgreementStatus === "PENDING" && vippsConfirmationUrl) {
      return (
        <>
          <p className="mb-2">
            Du har en pågående registrering for et abonnement. Gå til Vipps for
            å fullføre registreringen.
          </p>

          <VippsButton text="Gå til" link={vippsConfirmationUrl} />
        </>
      );
    }
  }

  var formattedNextChargeDate =
    nextChargeDate != null
      ? format(parse(nextChargeDate, "yyyy-mm-dd", new Date()), "dd.mm.yyyy")
      : null;

  if (subscriptionType === "Vipps" && vippsAgreementStatus == "UNSUBSCRIBED") {
    return (
      <>
        <p className="mb-2">
          Du har sagt opp abonnementet ditt. Du har fortsatt tilgang frem til{" "}
          {formattedNextChargeDate}.
        </p>

        <Button
          variant="green"
          className="rounded"
          disabled={reactivateSubscription.isPending}
          onClick={() => reactivateSubscription.mutate()}
        >
          Re-aktiver abonnement
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
          Du har sagt opp abonnementet ditt. Du har fortsatt tilgang frem til{" "}
          {formattedNextChargeDate}.
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
            Du har registrert et abonnement på appen. Tusen takk!{" "}
            {formattedNextChargeDate &&
              `Abonnementet fornyes automatisk ${formattedNextChargeDate}`}
          </p>

          {subscriptionType == "Vipps" && (
            <Button
              variant="secondary"
              className="rounded"
              disabled={stopSubscription.isPending}
              onClick={() => stopSubscription.mutate()}
            >
              Avslutt abonnement
            </Button>
          )}

          {subscriptionType == "Stripe" && <StripeCustomerPortalButton />}
        </>
      )}
    </>
  );
};
