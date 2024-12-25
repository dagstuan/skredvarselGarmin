import {
  Spinner,
  Button,
  Text,
  VStack,
  AbsoluteCenter,
  Box,
  Divider,
} from "@chakra-ui/react";
import { format, parse } from "date-fns";
import {
  useReactivateVippsAgreement,
  useStopVippsAgreement,
  useSubscription,
} from "../../hooks/useSubscription";
import { VippsButton } from "../Buttons/VippsButton";
import { StripeButton } from "../Buttons/StripeButton";

const StripeCustomerPortalButton = () => (
  <Button
    as="a"
    href="/stripe-customer-portal"
    colorScheme="blue"
    borderRadius={4}
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
    return <Spinner />;
  }

  if (!subscription) {
    return (
      <VStack align="flex-start" gap={2}>
        <Text mb={2}>Du har ikke registrert et abonnement på appen.</Text>

        <VStack gap={5} alignItems="stretch">
          <VippsButton />
          <Box position="relative">
            <Divider />
            <AbsoluteCenter bg="white" px="4">
              Eller
            </AbsoluteCenter>
          </Box>
          <StripeButton />
        </VStack>
      </VStack>
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
          <Text mb={2}>
            Du har en pågående registrering for et abonnement. Gå til Vipps for
            å fullføre registreringen.
          </Text>

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
        <Text mb={2}>
          Du har sagt opp abonnementet ditt. Du har fortsatt tilgang frem til{" "}
          {formattedNextChargeDate}.
        </Text>

        <Button
          colorScheme="green"
          borderRadius={4}
          isDisabled={reactivateSubscription.isPending}
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
        <Text mb={2}>
          Du har sagt opp abonnementet ditt. Du har fortsatt tilgang frem til{" "}
          {formattedNextChargeDate}.
        </Text>

        <StripeCustomerPortalButton />
      </>
    );
  }

  return (
    <>
      {subscription != null && (
        <>
          <Text mb={2}>
            Du har registrert et abonnement på appen. Tusen takk!{" "}
            {formattedNextChargeDate &&
              `Abonnementet fornyes automatisk ${formattedNextChargeDate}`}
          </Text>

          {subscriptionType == "Vipps" && (
            <Button
              colorScheme="gray"
              borderRadius={4}
              isDisabled={stopSubscription.isPending}
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
