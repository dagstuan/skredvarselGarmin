import { Button, ButtonProps, Flex, Text } from "@chakra-ui/react";

import { VippsIcon } from "../Icons/VippsIcon";

type VippsButtonProps = {
  text?: string;
  link?: string;
} & Pick<ButtonProps, "size">;

export const VippsButton = (props: VippsButtonProps) => {
  const { text = "Fortsett med", link = "/createVippsAgreement" } = props;

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
      <Flex gap={2} alignItems="center">
        <Text>{text}</Text>
        <VippsIcon alignSelf="flex-end" w={14} h={4} />
      </Flex>
    </Button>
  );
};
