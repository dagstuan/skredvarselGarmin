import { Button, Flex } from "@chakra-ui/react";

import vippsLogoWhite from "../assets/vipps_logo_white.svg";

type VippsButton = {
  text?: string;
  link?: string;
};

export const VippsButton = (props: VippsButton) => {
  const { text = "Kjøp abonnement med", link = "/createSubscription" } = props;

  return (
    <Button
      as="a"
      href={link}
      bg={"#ff5b24"}
      color={"white"}
      rounded={"full"}
      borderRadius={4}
      _hover={{ bg: "#ec6638" }}
    >
      <Flex gap={2} alignItems="flex-end">
        <span>{text}</span>
        <img src={vippsLogoWhite} />
      </Flex>
    </Button>
  );
};
