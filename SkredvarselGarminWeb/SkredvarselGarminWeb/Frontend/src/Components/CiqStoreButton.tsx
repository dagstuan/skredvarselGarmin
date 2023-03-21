import { Button, Flex, Text } from "@chakra-ui/react";

import ciqLogo from "../assets/ciq_logo.png";

export const CiqStoreButton = () => {
  return (
    <Button
      as="a"
      target="_blank"
      href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
      bg={"#0e334c"}
      color={"white"}
      rounded={"full"}
      borderRadius={4}
      px={2}
      _hover={{ bg: "#0a1f2e" }}
    >
      <Flex gap={2} h="inherit" p={1} alignItems="center">
        <img style={{ width: "auto", height: "100%" }} src={ciqLogo} />
        <Flex direction="column">
          <Text fontSize="xs">Last ned på</Text>
          <Text>Connect IQ Store</Text>
        </Flex>
      </Flex>
    </Button>
  );
};
