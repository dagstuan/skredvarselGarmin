import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalCloseButton,
  ModalBody,
  VStack,
} from "@chakra-ui/react";
import { FacebookButton } from "./Buttons/FacebookButton";
import { GoogleButton } from "./Buttons/GoogleButton";
import { VippsButton } from "./Buttons/VippsButton";
import { useLocation } from "react-router-dom";
import { useNavigateOnClose } from "../hooks/useNavigateOnClose";

export const LoginModal = () => {
  const location = useLocation();

  const isOnLoginPage = location.pathname.toLowerCase() == "/login";

  const { isClosing, onClose } = useNavigateOnClose("/");

  return (
    <Modal isOpen={isOnLoginPage && !isClosing} onClose={onClose} isCentered>
      <ModalOverlay />
      <ModalContent alignItems="center">
        <ModalHeader>Logg inn</ModalHeader>
        <ModalCloseButton />
        <ModalBody w="100%" pb={9} maxW="sm">
          <VStack gap={5} alignItems="stretch">
            <VippsButton
              link="/vipps-login?returnUrl=/account"
              text="Fortsett med"
            />
            <GoogleButton link="/google-login?returnUrl=/account" />
            <FacebookButton link="/facebook-login?returnUrl=/account" />
          </VStack>
        </ModalBody>
      </ModalContent>
    </Modal>
  );
};
