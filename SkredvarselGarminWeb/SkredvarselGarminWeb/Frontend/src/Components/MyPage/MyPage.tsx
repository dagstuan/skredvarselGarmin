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
import { useLocation, useNavigate } from "react-router-dom";
import { useUser } from "../../hooks/useUser";
import { PersonalInfo } from "./PersonalInfo";
import { Subscription } from "./Subscription";
import { Watches } from "./Watches";
import { Link as RouterLink } from "react-router-dom";

export const MyPage = () => {
  const { data: user, isLoading } = useUser();

  const navigate = useNavigate();
  const location = useLocation();

  const isOnMinSide = location.pathname == "/minSide";

  if (isOnMinSide && !isLoading && !user) {
    window.location.href = "/vipps-login?returnUrl=/minSide";
    return null;
  }

  return (
    <Drawer isOpen={isOnMinSide} onClose={() => navigate("/")} size="md">
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

          <Box>
            <Button
              as="a"
              href="/vipps-logout"
              bg={"blue.400"}
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
