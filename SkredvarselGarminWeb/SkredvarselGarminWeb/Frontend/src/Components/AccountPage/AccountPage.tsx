import {
  Box,
  Button,
  Drawer,
  DrawerBody,
  DrawerCloseButton,
  DrawerContent,
  DrawerOverlay,
  Heading,
  Text,
  Link,
} from "@chakra-ui/react";
import { useNavigate } from "react-router-dom";
import { useUser } from "../../hooks/useUser";
import { PersonalInfo } from "./PersonalInfo";
import { Subscription } from "./Subscription";
import { Watches } from "./Watches";
import { Link as RouterLink } from "react-router-dom";
import { useNavigateOnClose } from "../../hooks/useNavigateOnClose";
import { useEffect } from "react";

export const AccountPage = () => {
  const { data: user, isLoading: isLoadingUser } = useUser();

  const navigate = useNavigate();

  const { isClosing, onClose } = useNavigateOnClose("/");

  useEffect(() => {
    if (!user && !isLoadingUser) {
      navigate("/login");
    }
  }, [user, isLoadingUser]);

  return (
    <Drawer isOpen={!!user && !isClosing} onClose={onClose} size="md">
      <DrawerOverlay />
      <DrawerContent>
        <DrawerCloseButton />

        <DrawerBody>
          <Heading size="md" mt={2} mb={8}>
            Min side
          </Heading>

          <Text mb={10}>
            Lurer du på noe? Se{" "}
            <Link as={RouterLink} to="/faq" color="blue.600">
              ofte stilte spørsmål
            </Link>
            .
          </Text>

          <Box mb={10}>
            <Heading size="sm" mb={2}>
              Abonnement
            </Heading>

            <Subscription />
          </Box>

          <Box mb={10}>
            <Watches />
          </Box>

          <Box mb={10}>
            <Heading size="sm" mb={2}>
              Personlige opplysninger
            </Heading>

            <PersonalInfo />
          </Box>

          <Box mb={5}>
            <Button as="a" href="/logout" colorScheme="blue" borderRadius={4}>
              Logg ut
            </Button>
          </Box>
        </DrawerBody>
      </DrawerContent>
    </Drawer>
  );
};
