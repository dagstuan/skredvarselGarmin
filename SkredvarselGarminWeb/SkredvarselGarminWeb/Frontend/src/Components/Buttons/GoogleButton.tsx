import { Button, Flex, Icon, Text } from "@chakra-ui/react";
import { FcGoogle } from "react-icons/fc";

type GoogleButtonProps = {
  link: string;
};

export const GoogleButton = ({ link }: GoogleButtonProps) => {
  return (
    <Button
      as="a"
      href={link}
      rounded={"full"}
      borderColor="black"
      borderRadius={4}
      colorScheme="gray"
      variant="outline"
      size={"md"}
    >
      <Flex gap={2} alignItems="center">
        <Icon as={FcGoogle} w={6} h={6} />
        <Text>Logg inn med Google</Text>
      </Flex>
    </Button>
  );
};
