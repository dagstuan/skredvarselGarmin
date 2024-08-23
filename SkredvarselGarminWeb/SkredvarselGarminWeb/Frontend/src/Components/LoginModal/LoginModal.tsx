import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalCloseButton,
  ModalBody,
  Icon,
  Box,
  Center,
  Text,
  VStack,
} from "@chakra-ui/react";
import { useNavigateOnClose } from "../../hooks/useNavigateOnClose";
import { useState } from "react";
import { LoginContent } from "./LoginContent";

import { FaPaperPlane } from "react-icons/fa";
import { useEmailLogin } from "../../hooks/useEmailLogin";

type LoginModalProps = {
  loginText?: string;
};

export const LoginModal = (props: LoginModalProps) => {
  const { loginText } = props;

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
    <Modal isOpen={!isClosing} onClose={onClose} isCentered>
      <ModalOverlay />
      <ModalContent alignItems="center">
        <ModalHeader>
          {!showSentEmail ? "Logg inn" : "E-post sendt"}
        </ModalHeader>
        <ModalCloseButton />
        <ModalBody w="100%" pb={9} maxW="sm">
          {!showSentEmail && (
            <LoginContent
              loginText={loginText}
              email={email}
              handleEmailInputChange={handleEmailInputChange}
              handleSubmit={handleSubmit}
              error={error}
              isLoading={isLoading}
            />
          )}
          {showSentEmail && (
            <VStack gap={6}>
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
