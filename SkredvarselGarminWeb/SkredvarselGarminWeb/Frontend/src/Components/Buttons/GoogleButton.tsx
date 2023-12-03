import { Button, Flex, Text } from "@chakra-ui/react";

import googleLogo from "../../assets/google_logo.svg";

type GoogleButtonProps = {
  link: string;
};

export const GoogleButton = ({ link }: GoogleButtonProps) => {
  return (
    <Button
      as="a"
      href={link}
      bg="white"
      color="black.500"
      rounded={"full"}
      borderRadius={4}
      colorScheme="gray"
      border="1px"
      borderColor="gray.300"
      size={"md"}
    >
      <Flex gap={2} alignItems="flex-end">
        <img src={googleLogo} />
        <Text>Fortsett med Google</Text>
      </Flex>
    </Button>
  );
};
