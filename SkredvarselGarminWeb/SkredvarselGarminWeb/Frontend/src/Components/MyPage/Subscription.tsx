import { Spinner, Button, Text } from "@chakra-ui/react";
import { format, parse } from "date-fns";
import {
  useReactivateSubscription,
  useStopSubscription,
  useSubscription,
} from "../../hooks/useSubscription";
import { VippsButton } from "../VippsButton";

export const Subscription = () => {
  const { data: subscription, isLoading: isSubscriptionLoading } =
    useSubscription();

  const stopSubscription = useStopSubscription();
  const reactivateSubscription = useReactivateSubscription();

  if (isSubscriptionLoading) {
    return <Spinner />;
  }

  if (
    !subscription ||
    subscription.status == "STOPPED" ||
    subscription.status == "EXPIRED"
  ) {
    return (
      <>
        <Text mb={2}>
          Du har ikke registrert et abonnement på appen. Gå til Vipps for å
          registrere deg.
        </Text>

        <VippsButton />
      </>
    );
  }

  if (subscription.status == "PENDING" && subscription.vippsConfirmationUrl) {
    return (
      <>
        <Text mb={2}>
          Du har en pågående registrering for et abonnement. Gå til Vipps for å
          fullføre registreringen.
        </Text>

        <VippsButton text="Gå til" link={subscription.vippsConfirmationUrl} />
      </>
    );
  }

  var nextChargeDate =
    subscription.nextChargeDate != null
      ? format(
          parse(subscription.nextChargeDate, "yyyy-mm-dd", new Date()),
          "dd.mm.yyyy",
        )
      : null;

  if (subscription.status == "UNSUBSCRIBED") {
    return (
      <>
        <Text mb={2}>
          Du har sagt opp abonnementet ditt. Du har fortsatt tilgang frem til{" "}
          {nextChargeDate}.
        </Text>

        <Button
          colorScheme="green"
          isDisabled={reactivateSubscription.isLoading}
          onClick={() => reactivateSubscription.mutate()}
        >
          Re-aktiver abonnement
        </Button>
      </>
    );
  }

  return (
    <>
      {subscription != null && (
        <>
          <Text mb={2}>
            Du har registrert et abonnement på appen. Tusen takk!{" "}
            {nextChargeDate &&
              `Abonnementet fornyes automatisk ${nextChargeDate}`}
          </Text>

          <Button
            color="gray.500"
            isDisabled={stopSubscription.isLoading}
            onClick={() => stopSubscription.mutate()}
          >
            Avslutt abonnement
          </Button>
        </>
      )}
    </>
  );
};
