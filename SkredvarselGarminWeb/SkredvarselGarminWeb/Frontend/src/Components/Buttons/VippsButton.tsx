import { Button, ButtonProps, Flex, Text } from "@chakra-ui/react";

import vippsLogoWhite from "../../assets/vipps_logo_white.svg";

type VippsButtonProps = {
  text?: string;
  link?: string;
} & Pick<ButtonProps, "size">;

export const VippsButton = (props: VippsButtonProps) => {
  const { text = "Kjøp abonnement med", link = "/createVippsAgreement" } =
    props;

  return (
    <Button
      as="a"
      href={link}
      bg={"#ff5b24"}
      color={"white"}
      rounded={"full"}
      borderRadius={4}
      size={props.size ?? "md"}
      _hover={{ bg: "#ec6638" }}
    >
      <Flex gap={2} alignItems="flex-end">
        <Text>{text}</Text>
        <img src={vippsLogoWhite} />
      </Flex>
    </Button>
  );
};
