import { Image, Box, Button, Flex, Heading } from "@chakra-ui/react";

import avalancheIcon from "./assets/avalanche_icon.svg";

export const Nav = () => {
  return (
    <Flex justifyContent={"center"} px={4} bg="whiteAlpha.800">
      <Flex
        w={"100%"}
        maxW={"5xl"}
        h={20}
        alignItems={"center"}
        justifyContent={"space-between"}
      >
        <Flex gap={3} alignItems={"center"}>
          <Image h={10} src={avalancheIcon} alt="Avalanche icon" />
          <Heading as="h1" size="xl" noOfLines={1}>
            Skredvarsel for Garmin
          </Heading>
        </Flex>

        <Box>
          <Button
            bg={"blue.400"}
            rounded={"full"}
            color={"white"}
            _hover={{ bg: "blue.500" }}
          >
            Logg inn og kjøp abonnement
          </Button>
        </Box>
      </Flex>
    </Flex>
  );
};
