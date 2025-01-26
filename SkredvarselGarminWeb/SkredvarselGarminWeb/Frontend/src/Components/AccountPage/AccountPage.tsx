import {
  Box,
  Button,
  Drawer,
  DrawerBody,
  DrawerCloseButton,
  DrawerContent,
  DrawerOverlay,
  Heading,
  Link,
  Text,
} from "@chakra-ui/react";
import { useEffect } from "react";
import {
  Link as RouterLink,
  useNavigate,
  useSearchParams,
} from "react-router-dom";
import { useNavigateOnClose } from "../../hooks/useNavigateOnClose";
import { useUser } from "../../hooks/useUser";
import { useAddWatch } from "../../hooks/useWatches";
import { PersonalInfo } from "./PersonalInfo";
import { Subscription } from "./Subscription";
import { Watches } from "./Watches";

export const AccountPage = () => {
  const { data: user, isLoading: isLoadingUser } = useUser();

  const navigate = useNavigate();

  const { isClosing, onClose } = useNavigateOnClose("/");

  useEffect(() => {
    if (!user && !isLoadingUser) {
      navigate("/login");
    }
  }, [user, isLoadingUser]);

  const [searchParams, setSearchParams] = useSearchParams();
  const watchKey = searchParams.get("watchKey");

  const { mutate: mutateAddWatch, isPending: isAddWatchPending } = useAddWatch(
    () => {
      searchParams.delete("watchKey");
      setSearchParams(searchParams, {
        replace: true,
        preventScrollReset: true,
      });
    },
  );

  useEffect(() => {
    if (user && watchKey && !isAddWatchPending) {
      mutateAddWatch(watchKey);
    }
  }, [mutateAddWatch, isAddWatchPending, user, watchKey]);

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
