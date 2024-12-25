import { Button, Flex, Icon, Text } from "@chakra-ui/react";
import { SiFacebook } from "react-icons/si";

type FacebookButtonProps = {
  link: string;
};

export const FacebookButton = ({ link }: FacebookButtonProps) => {
  return (
    <Button
      as="a"
      href={link}
      rounded={"full"}
      borderRadius={4}
      colorScheme="facebook"
      size={"md"}
    >
      <Flex gap={2} alignItems="center">
        <Icon as={SiFacebook} w={6} h={6} />
        <Text>Logg inn med Facebook</Text>
      </Flex>
    </Button>
  );
};
