import { Button, ButtonProps, Flex, Img, Text } from "@chakra-ui/react";

import stripeLogo from "../../assets/stripe_logo.svg";

type StripeButtonProps = {
  text?: string;
  link?: string;
} & Pick<ButtonProps, "size">;

export const StripeButton = (props: StripeButtonProps) => {
  const { text = "Kjøp abonnement med", link = "/createStripeSubscription" } =
    props;

  return (
    <Button
      as="a"
      href={link}
      bg="white"
      color="#30313d"
      rounded={"full"}
      borderRadius={4}
      border="2px"
      borderColor="#0570DE"
      size={props.size ?? "md"}
      colorScheme="gray"
    >
      <Flex gap={2} alignItems="flex-start">
        <Text>{text}</Text>
        <Img src={stripeLogo} />
      </Flex>
    </Button>
  );
};
