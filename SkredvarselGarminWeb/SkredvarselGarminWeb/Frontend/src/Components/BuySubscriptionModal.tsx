import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalCloseButton,
  ModalBody,
  Text,
  VStack,
  Box,
  Icon,
  Button,
  FormControl,
  FormErrorMessage,
  Input,
  Center,
  Heading,
} from "@chakra-ui/react";
import { VippsButton } from "./Buttons/VippsButton";
import { FacebookButton } from "./Buttons/FacebookButton";
import { GoogleButton } from "./Buttons/GoogleButton";
import { FaPaperPlane } from "react-icons/fa";
import { useNavigateOnClose } from "../hooks/useNavigateOnClose";
import { useUser } from "../hooks/useUser";
import { useNavigateToAccountIfLoggedIn } from "../hooks/useNavigateToAccountIfLoggedIn";
import { OrDivider } from "./OrDivider";
import { useEmailLogin } from "../hooks/useEmailLogin";
import { EmailLoginForm } from "./EmailLoginForm/EmailLoginForm";

export const BuySubscriptionModal = () => {
  const { data: user, isLoading: isLoadingUser } = useUser();

  useNavigateToAccountIfLoggedIn(user, isLoadingUser);

  const { isClosing, onClose } = useNavigateOnClose("/");

  const {
    email,
    showSentEmail,
    error,
    handleEmailInputChange,
    handleSubmit,
    isLoading,
  } = useEmailLogin();

  return (
    <Modal isOpen={!isLoadingUser && !isClosing} onClose={onClose} isCentered>
      <ModalOverlay />
      <ModalContent alignItems="center" overflow="hidden">
        <ModalHeader>Kjøp abonnement</ModalHeader>
        <ModalCloseButton />
        <ModalBody w="100%" p={0}>
          {!showSentEmail && (
            <VStack gap={8} w="100%" alignItems="center">
              <VStack gap={5} w="80%" alignItems="center">
                <Text fontSize="md" align="center">
                  Abonnement kan kjøpes direkte med Vipps,
                  <br />
                  eller logg inn for andre alternativer.
                </Text>

                <VStack w="100%" alignItems="stretch">
                  <VippsButton />
                </VStack>
              </VStack>

              <Center w="100%" bg="gray.100" pt={4} pb={6}>
                <VStack w="80%" maxW="sm" gap={5} alignItems="stretch">
                  <Heading
                    textAlign="center"
                    as="header"
                    size="sm"
                    fontWeight="normal"
                  >
                    Logg inn / registrer deg
                  </Heading>
                  <VStack gap={5} w="100%" alignItems="stretch">
                    <VStack gap={2} w="100%" alignItems="stretch">
                      <GoogleButton link="/google-login?returnUrl=/account" />
                      <FacebookButton link="/facebook-login?returnUrl=/account" />
                    </VStack>

                    <OrDivider text="Eller" />
                    <VStack w="100%" alignItems="stretch">
                      <EmailLoginForm
                        email={email}
                        handleEmailInputChange={handleEmailInputChange}
                        handleSubmit={handleSubmit}
                        error={error}
                        isLoading={isLoading}
                      />
                    </VStack>
                  </VStack>
                </VStack>
              </Center>
            </VStack>
          )}
          {showSentEmail && (
            <VStack gap={6} pb={6}>
              <Box
                display="flex"
                alignItems="center"
                justifyContent="center"
                bg="green.500"
                color="white"
                borderRadius="50%"
                boxSize={28}
              >
                <Icon w={16} h={16} as={FaPaperPlane} />
              </Box>
              <Text>Sjekk innboksen din for en innloggingslenke.</Text>
            </VStack>
          )}
        </ModalBody>
      </ModalContent>
    </Modal>
  );
};
