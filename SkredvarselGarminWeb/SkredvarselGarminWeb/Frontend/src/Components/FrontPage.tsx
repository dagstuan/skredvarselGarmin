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
} from "@chakra-ui/react";
import { Features } from "./Features";

import bg from "../assets/bg.jpg?format=webp&as=source&imagetools";
import { CiqStoreButton } from "./CiqStoreButton";
import { useScrollPosition } from "../hooks/useScrollPosition";
import { ChevronIcon } from "./Icons/ChevronIcon";
import {
  FaApplePay,
  FaCreditCard,
  FaGooglePay,
  FaSkiing,
  FaSkiingNordic,
} from "react-icons/fa";
import { VippsIcon } from "./Icons/VippsIcon";
import { useUser } from "../hooks/useUser";
import { useCallback } from "react";
import { Outlet, useNavigate } from "react-router-dom";

export const FrontPage = () => {
  const scrollPosition = useScrollPosition();
  const { data: user } = useUser();
  const navigate = useNavigate();

  const onBuyClick = useCallback(() => {
    if (user) {
      navigate("/account");
    } else {
      navigate("/subscribe");
    }
  }, [navigate, user]);

  return (
    <>
      <Flex
        w="full"
        h="calc(100vh - var(--chakra-sizes-20))"
        flexDir="column"
        backgroundImage={bg}
        backgroundSize="cover"
        backgroundPosition="center center"
      >
        <Box
          w="full"
          h="calc(100vh - var(--chakra-sizes-20))"
          bgGradient="linear(to-r, blackAlpha.500, transparent)"
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
              <Stack
                boxShadow="0px 0px 100px 100px var(--chakra-colors-blackAlpha-200);"
                bg="blackAlpha.200"
                rounded="2xl"
                maxW="4xl"
                align="flex-start"
                spacing={6}
              >
                <Text
                  color="white"
                  fontWeight={700}
                  lineHeight={1.2}
                  fontSize={useBreakpointValue({ base: "3xl", md: "4xl" })}
                >
                  Skredvarsel for Garmin-klokker.
                  <br />
                  Oppdatert og tilgjengelig mens du er på tur.
                </Text>
                <Stack direction="row" align="center" justify="center">
                  <Text color="white" fontSize="3xl" fontWeight={800}>
                    30 kr
                  </Text>
                  <Text fontSize="xl" color="white">
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
                        Kjøp abonnement
                      </Button>
                      <HStack alignItems="center">
                        <VippsIcon
                          title="Vipps"
                          color="white"
                          w={14}
                          h="100%"
                        />
                        <Icon
                          title="Kort"
                          color="white"
                          as={FaCreditCard}
                          w={7}
                          h="100%"
                        />
                        <Icon
                          title="Apple Pay"
                          color="white"
                          as={FaApplePay}
                          w={9}
                          h="100%"
                        />
                        <Icon
                          title="Google Pay"
                          color="white"
                          as={FaGooglePay}
                          w={9}
                          h="100%"
                        />
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
      <Outlet />
    </>
  );
};
