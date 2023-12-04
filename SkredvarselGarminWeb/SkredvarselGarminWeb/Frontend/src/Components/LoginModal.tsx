import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalCloseButton,
  ModalBody,
  VStack,
} from "@chakra-ui/react";
import { GoogleButton } from "./Buttons/GoogleButton";
import { VippsButton } from "./Buttons/VippsButton";

type LoginModalProps = {
  isOpen: boolean;
  onClose: () => void;
};

export const LoginModal = (props: LoginModalProps) => {
  const { isOpen, onClose } = props;

  return (
    <Modal isOpen={isOpen} onClose={onClose} isCentered>
      <ModalOverlay />
      <ModalContent alignItems="center">
        <ModalHeader>Logg inn</ModalHeader>
        <ModalCloseButton />
        <ModalBody w="100%" pb={9} maxW="sm">
          <VStack gap={5} alignItems="stretch">
            <VippsButton
              link="/vipps-login?returnUrl=/minSide"
              text="Fortsett med"
            />
            <GoogleButton link="/google-login?returnUrl=/minSide" />
          </VStack>
        </ModalBody>
      </ModalContent>
    </Modal>
  );
};
