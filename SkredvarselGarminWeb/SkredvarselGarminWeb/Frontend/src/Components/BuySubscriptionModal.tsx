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
  AbsoluteCenter,
  Divider,
  Icon,
  HStack,
} from "@chakra-ui/react";
import { VippsButton } from "./Buttons/VippsButton";
import { FacebookButton } from "./Buttons/FacebookButton";
import { GoogleButton } from "./Buttons/GoogleButton";
import { VippsIcon } from "./Icons/VippsIcon";
import {
  FaApplePay,
  FaCcMastercard,
  FaCcVisa,
  FaGooglePay,
} from "react-icons/fa";

export type BuySubscriptionModalProps = {
  isOpen: boolean;
  onClose: () => void;
};

export const BuySubscriptionModal = (props: BuySubscriptionModalProps) => {
  const { isOpen, onClose } = props;

  return (
    <Modal isOpen={isOpen} onClose={onClose} isCentered>
      <ModalOverlay />
      <ModalContent alignItems="center">
        <ModalHeader>Kjøp abonnement</ModalHeader>
        <ModalCloseButton />
        <ModalBody w="100%" pb={9}>
          <VStack gap={2} w="100%">
            <Text fontSize="md" align="center">
              Du må være logget inn for å kjøpe abonnement.
            </Text>

            <VStack gap={2} mb={7}>
              <Text>Du kan betale med:</Text>
              <HStack>
                <VippsIcon w={14} h={4} /> <Icon as={FaCcVisa} w={7} h={7} />
                <Icon as={FaCcMastercard} w={7} h={7} />
                <Icon as={FaApplePay} w={9} h={9} />
                <Icon as={FaGooglePay} w={9} h={9} />
              </HStack>
            </VStack>

            <VStack w="100%" maxW="sm" gap={5} alignItems="stretch">
              <VippsButton />
              <Box mb={2} mt={2} position="relative">
                <Divider />
                <AbsoluteCenter bg="white" px="4">
                  Eller
                </AbsoluteCenter>
              </Box>
              <GoogleButton link="/google-login?returnUrl=/minSide" />
              <FacebookButton link="/facebook-login?returnUrl=/minSide" />
            </VStack>
          </VStack>
        </ModalBody>
      </ModalContent>
    </Modal>
  );
};
