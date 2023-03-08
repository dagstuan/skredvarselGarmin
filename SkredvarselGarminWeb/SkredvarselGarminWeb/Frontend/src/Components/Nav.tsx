import {
  Image,
  Link,
  Box,
  Button,
  Flex,
  Heading,
  Spinner,
} from "@chakra-ui/react";
import { Link as RouterLink } from "react-router-dom";

import avalancheIcon from "../assets/avalanche_icon.svg";
import { useUser } from "../hooks/useUser";

export const Nav = () => {
  const { data: user, isLoading } = useUser();

  return (
    <Flex justifyContent={"center"} px={4} bg="gray.100">
      <Flex
        w={"100%"}
        maxW={"100%"}
        h={20}
        alignItems={"center"}
        justifyContent={"space-between"}
      >
        <Link style={{ textDecoration: "none" }} as={RouterLink} to="/">
          <Flex gap={3} alignItems={"center"}>
            <Image h={10} src={avalancheIcon} alt="Avalanche icon" />
            <Heading as="h1" size="xl" noOfLines={1}>
              Skredvarsel for Garmin
            </Heading>
          </Flex>
        </Link>

        <Box>
          {isLoading ? (
            <Spinner />
          ) : !user ? (
            <Button
              as="a"
              href="/vipps-login?returnUrl=/"
              bg={"blue.400"}
              rounded={"full"}
              color={"white"}
              _hover={{ bg: "blue.500" }}
            >
              Logg inn og kjøp abonnement
            </Button>
          ) : (
            <Button
              as="a"
              href="/vipps-logout"
              isLoading={isLoading}
              bg={"blue.400"}
              rounded={"full"}
              color={"white"}
              _hover={{ bg: "blue.500" }}
            >
              Logg ut
            </Button>
          )}
        </Box>
      </Flex>
    </Flex>
  );
};
