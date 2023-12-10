import {
  Flex,
  VStack,
  useBreakpointValue,
  Stack,
  Text,
  Wrap,
  WrapItem,
  SlideFade,
  Box,
  Button,
  Icon,
  HStack,
  useDisclosure,
} from "@chakra-ui/react";
import { Features } from "./Features";

import bg from "../assets/bg.jpg";
import { MyPage } from "./MyPage/MyPage";
import { CiqStoreButton } from "./CiqStoreButton";
import { useScrollPosition } from "../hooks/useScrollPosition";
import { ChevronIcon } from "./ChevronIcon";
import {
  FaApplePay,
  FaCcMastercard,
  FaCcVisa,
  FaGooglePay,
  FaSkiing,
  FaSkiingNordic,
} from "react-icons/fa";
import { VippsIcon } from "./Icons/VippsIcon";
import { BuySubscriptionModal } from "./BuySubscriptionModal";
import { useUser } from "../hooks/useUser";
import { useCallback } from "react";
import { useNavigate } from "react-router-dom";

export const FrontPage = () => {
  const scrollPosition = useScrollPosition();
  const { data: user } = useUser();
  const navigate = useNavigate();

  const {
    isOpen: isLoginOpen,
    onOpen: onLoginOpen,
    onClose: onLoginClose,
  } = useDisclosure();

  const onBuyClick = useCallback(() => {
    if (user) {
      navigate("/minSide");
    } else {
      onLoginOpen();
    }
  }, [navigate, user, onLoginOpen]);

  return (
    <>
      <Flex
        w={"full"}
        h={"calc(100vh - var(--chakra-sizes-20))"}
        flexDir={"column"}
        backgroundImage={bg}
        backgroundSize={"cover"}
        backgroundPosition={"center center"}
      >
        <Box
          w="full"
          h={"calc(100vh - var(--chakra-sizes-20))"}
          bgGradient={"linear(to-r, blackAlpha.500, transparent)"}
          display="flex"
          flexDirection="column"
          alignItems="center"
        >
          <VStack
            flex="1 1 100%"
            justifyContent="center"
            px={useBreakpointValue({ base: 4, md: 8 })}
          >
            <VStack>
              <Stack pb="42px" maxW={"4xl"} align={"flex-start"} spacing={6}>
                <Text
                  color={"white"}
                  fontWeight={700}
                  lineHeight={1.2}
                  fontSize={useBreakpointValue({ base: "3xl", md: "4xl" })}
                >
                  Skredvarsel for Garmin-klokker.
                  <br />
                  Oppdatert og tilgjengelig mens du er på tur.
                </Text>
                <Stack direction={"row"} align={"center"} justify={"center"}>
                  <Text color={"white"} fontSize={"3xl"} fontWeight={800}>
                    30 kr
                  </Text>
                  <Text fontSize={"xl"} color={"white"}>
                    /år
                  </Text>
                </Stack>
                <Wrap spacing={2}>
                  <WrapItem>
                    <CiqStoreButton size="lg" />
                  </WrapItem>
                  <WrapItem>
                    <VStack gap={1} align="flex-start">
                      <Button
                        leftIcon={<Icon as={FaSkiingNordic} />}
                        rightIcon={<Icon as={FaSkiing} />}
                        onClick={onBuyClick}
                        size="lg"
                        colorScheme="green"
                      >
                        Logg inn og kjøp abonnement
                      </Button>
                      <HStack>
                        <VippsIcon color="white" w={14} h={7} />
                        <Icon color="white" as={FaCcVisa} w={7} h={7} />
                        <Icon color="white" as={FaCcMastercard} w={7} h={7} />
                        <Icon color="white" as={FaApplePay} w={9} h={9} />
                        <Icon color="white" as={FaGooglePay} w={9} h={9} />
                      </HStack>
                    </VStack>
                  </WrapItem>
                </Wrap>
              </Stack>
            </VStack>
          </VStack>
          <SlideFade
            reverse={false}
            offsetY="20px"
            in={scrollPosition === 0}
            transition={{
              exit: {
                duration: 0.5,
              },
              enter: {
                duration: 0.75,
              },
            }}
          >
            <ChevronIcon
              color="white"
              opacity={0.6}
              mb={5}
              boxSize={useBreakpointValue({ base: 50, md: 100 })}
            />
          </SlideFade>
        </Box>
      </Flex>
      <Features />
      <MyPage />
      <BuySubscriptionModal isOpen={isLoginOpen} onClose={onLoginClose} />
    </>
  );
};
