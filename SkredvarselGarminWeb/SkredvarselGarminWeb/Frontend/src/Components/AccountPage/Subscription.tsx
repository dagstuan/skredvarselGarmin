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
import { Spinner } from "../ui/spinner";

const StripeCustomerPortalButton = () => (
  <Button
    nativeButton={false}
    render={(props) => <a {...props} href="/stripe-customer-portal" />}
    variant="blue"
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
        <Spinner className="size-5" />
      </div>
    );
  }

  if (!subscription) {
    return (
      <div className="flex flex-col items-start gap-2">
        <p className="mb-2">Du har ikke registrert et abonnement på appen.</p>

        <div className="flex flex-col gap-5">
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

  if (
    subscriptionType === "Vipps" &&
    vippsAgreementStatus === "PENDING" &&
    vippsConfirmationUrl
  ) {
    return (
      <div className="flex flex-col items-start gap-2">
        <p className="mb-2">
          Du har en pågående registrering for et abonnement. Gå til Vipps for å
          fullføre registreringen.
        </p>

        <VippsButton
          className="w-full cursor-pointer"
          text="Gå til"
          link={vippsConfirmationUrl}
        />
      </div>
    );
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
          disabled={reactivateSubscription.isPending}
          onClick={() => reactivateSubscription.mutate()}
        >
          Behold abonnementet
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
