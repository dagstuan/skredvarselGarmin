import {
  Image,
  Link,
  Box,
  Button,
  Flex,
  Heading,
  Spinner,
  useBreakpointValue,
  HStack,
  useDisclosure,
} from "@chakra-ui/react";
import { Link as RouterLink } from "react-router-dom";

import avalancheIcon from "../assets/avalanche_icon.svg";
import { useUser } from "../hooks/useUser";
import { LoginModal } from "./LoginModal";

export const Nav = () => {
  const { data: user, isLoading } = useUser();

  const {
    isOpen: isLoginOpen,
    onOpen: onLoginOpen,
    onClose: onLoginClose,
  } = useDisclosure();

  return (
    <>
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
              <Heading
                as="h1"
                size={useBreakpointValue({
                  base: "s",
                  md: "lg",
                })}
                noOfLines={1}
              >
                {useBreakpointValue({
                  base: "Skredvarsel",
                  sm: "Skredvarsel for Garmin",
                })}
              </Heading>
            </Flex>
          </Link>

          <Box>
            {isLoading ? (
              <Spinner />
            ) : !user ? (
              <>
                <Button
                  onClick={onLoginOpen}
                  bg={"blue.400"}
                  color={"white"}
                  _hover={{ bg: "blue.500" }}
                >
                  Logg inn
                </Button>
              </>
            ) : (
              <HStack gap={4}>
                {user.isAdmin && (
                  <Button
                    as={RouterLink}
                    to="/admin"
                    isLoading={isLoading}
                    bg={"blue.400"}
                    color={"white"}
                    _hover={{ bg: "blue.500" }}
                  >
                    Admin
                  </Button>
                )}
                <Button
                  as={RouterLink}
                  to="/minSide"
                  isLoading={isLoading}
                  bg={"blue.400"}
                  color={"white"}
                  _hover={{ bg: "blue.500" }}
                >
                  Min side
                </Button>
              </HStack>
            )}
          </Box>
        </Flex>
      </Flex>
      <LoginModal isOpen={isLoginOpen} onClose={onLoginClose} />
    </>
  );
};
