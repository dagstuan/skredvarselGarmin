import { Button, ButtonProps, HStack, Icon, VStack } from "@chakra-ui/react";
import {
  FaStripe,
  FaCcVisa,
  FaCcMastercard,
  FaApplePay,
  FaGooglePay,
  FaCreditCard,
} from "react-icons/fa";

type StripeButtonProps = {
  text?: string;
  link?: string;
} & Pick<ButtonProps, "size">;

export const StripeButton = (props: StripeButtonProps) => {
  const { text = "Kjøp abonnement med", link = "/createStripeSubscription" } =
    props;

  return (
    <VStack gap={0} alignItems="flex-start">
      <Button
        as="a"
        href={link}
        borderRadius={4}
        colorScheme="purple"
        size={props.size ?? "md"}
        rightIcon={<Icon as={FaStripe} h={10} w={12} />}
      >
        {text}
      </Button>
      <HStack alignItems="center">
        <Icon title="Kort" as={FaCreditCard} w={6} h="100%" />
        <Icon title="Apple pay" as={FaApplePay} w={9} h="100%" />
        <Icon title="Google pay" as={FaGooglePay} w={9} h="100%" />
      </HStack>
    </VStack>
  );
};
