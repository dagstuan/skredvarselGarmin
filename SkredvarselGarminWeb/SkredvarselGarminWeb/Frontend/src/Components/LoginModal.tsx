import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalCloseButton,
  ModalBody,
  VStack,
  Text,
} from "@chakra-ui/react";
import { FacebookButton } from "./Buttons/FacebookButton";
import { GoogleButton } from "./Buttons/GoogleButton";
import { VippsButton } from "./Buttons/VippsButton";
import { useNavigateOnClose } from "../hooks/useNavigateOnClose";

type LoginModalProps = {
  loginText?: string;
};

export const LoginModal = (props: LoginModalProps) => {
  const { loginText } = props;

  const { isClosing, onClose } = useNavigateOnClose("/");

  return (
    <Modal isOpen={!isClosing} onClose={onClose} isCentered>
      <ModalOverlay />
      <ModalContent alignItems="center">
        <ModalHeader>Logg inn</ModalHeader>
        <ModalCloseButton />
        <ModalBody w="100%" pb={9} maxW="sm">
          <VStack gap={7} alignItems="stretch">
            {loginText && (
              <Text fontSize="md" align="center" mb={2}>
                {loginText}
              </Text>
            )}

            <VStack gap={5} alignItems="stretch">
              <VippsButton
                link="/vipps-login?returnUrl=/account"
                text="Fortsett med"
              />
              <GoogleButton link="/google-login?returnUrl=/account" />
              <FacebookButton link="/facebook-login?returnUrl=/account" />
            </VStack>
          </VStack>
        </ModalBody>
      </ModalContent>
    </Modal>
  );
};
