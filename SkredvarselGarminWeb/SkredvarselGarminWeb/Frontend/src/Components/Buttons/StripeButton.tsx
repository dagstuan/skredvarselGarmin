import { Button, ButtonProps, HStack, Icon, VStack } from "@chakra-ui/react";
import {
  FaStripe,
  FaCcVisa,
  FaCcMastercard,
  FaApplePay,
  FaGooglePay,
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
      <HStack>
        <Icon as={FaCcVisa} w={6} h={6} />
        <Icon as={FaCcMastercard} w={6} h={6} />
        <Icon as={FaApplePay} w={9} h={9} />
        <Icon as={FaGooglePay} w={9} h={9} />
      </HStack>
    </VStack>
  );
};
