import {
  Box,
  Button,
  Drawer,
  DrawerBody,
  DrawerCloseButton,
  DrawerContent,
  DrawerOverlay,
  Flex,
  FormControl,
  FormHelperText,
  FormLabel,
  Heading,
  Input,
  Text,
} from "@chakra-ui/react";
import { useLocation, useNavigate } from "react-router-dom";
import { useUser } from "../../hooks/useUser";
import { PersonalInfo } from "./PersonalInfo";
import { Subscription } from "./Subscription";

export const MyPage = () => {
  const { data: user, isLoading } = useUser();

  const navigate = useNavigate();
  const location = useLocation();

  const isOnMinSide = location.pathname == "/minSide";

  if (isOnMinSide && !isLoading && !user) {
    window.location.href = "/vipps-login?returnUrl=/minSide";
  }

  return (
    <Drawer
      isOpen={!isLoading && !!user && isOnMinSide}
      onClose={() => navigate("/")}
      size="md"
    >
      <DrawerOverlay />
      <DrawerContent>
        <DrawerCloseButton />

        <DrawerBody>
          <Heading size="md" mt={2} mb={8}>
            Min side
          </Heading>

          <Box mb={10}>
            <Heading size="sm" mb={2}>
              Abonnement
            </Heading>

            <Subscription />
          </Box>

          <Box mb={10}>
            <Heading size="sm" mb={2}>
              Klokker
            </Heading>

            <Text mb={4}>Du har ikke lagt til noen klokker.</Text>

            <Box pt={4} pl={4} pb={4} pr={8} bg="gray.100">
              <FormControl mb={2}>
                <FormLabel>Legg til klokke</FormLabel>
                <Flex gap={4}>
                  <Input colorScheme="red" bg="white" />
                  <Button colorScheme="blue">Legg til</Button>
                </Flex>

                <FormHelperText>
                  Skriv inn koden som står på klokka.
                </FormHelperText>
              </FormControl>
            </Box>
          </Box>

          <Box mb={10}>
            <Heading size="sm" mb={2}>
              Personlige opplysninger
            </Heading>

            <PersonalInfo />
          </Box>

          <Box>
            <Button
              as="a"
              href="/vipps-logout"
              bg={"blue.400"}
              rounded={"full"}
              color={"white"}
              _hover={{ bg: "blue.500" }}
            >
              Logg ut
            </Button>
          </Box>
        </DrawerBody>
      </DrawerContent>
    </Drawer>
  );
};
