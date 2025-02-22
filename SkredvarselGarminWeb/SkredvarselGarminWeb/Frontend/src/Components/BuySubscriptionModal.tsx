import {
  Box,
  Center,
  Heading,
  Icon,
  Link,
  Modal,
  ModalBody,
  ModalCloseButton,
  ModalContent,
  ModalHeader,
  ModalOverlay,
  Text,
  VStack,
} from "@chakra-ui/react";
import { ReactElement } from "react";
import { FaPaperPlane } from "react-icons/fa";
import { Link as RouterLink, useSearchParams } from "react-router-dom";
import { useEmailLogin } from "../hooks/useEmailLogin";
import { useNavigateOnClose } from "../hooks/useNavigateOnClose";
import { useNavigateToAccountIfLoggedIn } from "../hooks/useNavigateToAccountIfLoggedIn";
import { useUser } from "../hooks/useUser";
import { FacebookButton } from "./Buttons/FacebookButton";
import { GoogleButton } from "./Buttons/GoogleButton";
import { VippsButton } from "./Buttons/VippsButton";
import { EmailLoginForm } from "./EmailLoginForm/EmailLoginForm";
import { OrDivider } from "./OrDivider";

type BuySubscriptionModalProps = {
  headerText?: string;
  informationElement?: ReactElement;
};

export const BuySubscriptionModal = (props: BuySubscriptionModalProps) => {
  const {
    headerText = "Kjøp abonnement",
    informationElement = (
      <>
        Abonnement kan kjøpes direkte med Vipps,
        <br />
        eller logg inn for andre alternativer.
        <br />
        <br />
        Hvis du allerede har et abonnement kan du logge inn nedenfor for å endre
        det.
      </>
    ),
  } = props;

  const [searchParams] = useSearchParams();
  const watchKey = searchParams.get("watchKey");

  const { data: user, isLoading: isLoadingUser } = useUser();

  useNavigateToAccountIfLoggedIn(user, isLoadingUser, watchKey);

  const { isClosing, onClose } = useNavigateOnClose("/");

  const {
    email,
    showSentEmail,
    error,
    handleEmailInputChange,
    handleSubmit,
    isPending,
  } = useEmailLogin(watchKey);

  return (
    <Modal isOpen={!isLoadingUser && !isClosing} onClose={onClose} isCentered>
      <ModalOverlay />
      <ModalContent alignItems="center" overflow="hidden">
        <ModalHeader>{headerText}</ModalHeader>
        <ModalCloseButton />
        <ModalBody w="100%" p={0}>
          {!showSentEmail && (
            <VStack gap={8} w="100%" alignItems="center">
              <VStack
                gap={5}
                w={{ base: "90%", md: "80%" }}
                alignItems="center"
              >
                <Box w="100%" p={3} boxShadow="xs" rounded="sm" bg="gray.50">
                  <Text fontSize="md" align="left">
                    {informationElement}
                  </Text>
                </Box>

                <VStack w="100%" alignItems="stretch">
                  <VippsButton
                    text="Kjøp abonnement med"
                    link={`/createVippsAgreement${watchKey ? `?watchKey=${watchKey}` : ""}`}
                  />
                </VStack>
              </VStack>

              <Center w="100%" bg="gray.100" pt={4} pb={8}>
                <VStack
                  w={{ base: "90%", md: "80%" }}
                  maxW="sm"
                  gap={5}
                  alignItems="stretch"
                >
                  <Heading
                    textAlign="center"
                    as="header"
                    size="sm"
                    fontWeight="bold"
                  >
                    Logg inn / registrer deg
                  </Heading>
                  <VStack gap={5} w="100%" alignItems="stretch">
                    <VStack gap={2} w="100%" alignItems="stretch">
                      <GoogleButton
                        link={`/google-login?returnUrl=/account${watchKey ? `?watchKey=${watchKey}` : ""}`}
                      />
                      <FacebookButton
                        link={`/facebook-login?returnUrl=/account${watchKey ? `?watchKey=${watchKey}` : ""}`}
                      />
                    </VStack>

                    <OrDivider text="Eller" />
                    <VStack w="100%" alignItems="stretch">
                      <EmailLoginForm
                        email={email}
                        handleEmailInputChange={handleEmailInputChange}
                        handleSubmit={handleSubmit}
                        error={error}
                        isLoading={isPending}
                      />
                    </VStack>
                    <Center>
                      <Link as={RouterLink} to="/faq#vippslogin">
                        Hvorfor kan jeg ikke logge inn med Vipps?
                      </Link>
                    </Center>
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
