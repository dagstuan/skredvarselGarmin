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
  useDisclosure,
} from "@chakra-ui/react";
import { Features } from "./Features";

import bg from "../assets/bg.jpg";
import { MyPage } from "./MyPage/MyPage";
import { VippsButton } from "./Buttons/VippsButton";
import { CiqStoreButton } from "./CiqStoreButton";
import { useScrollPosition } from "../hooks/useScrollPosition";
import { ChevronIcon } from "./ChevronIcon";

export const FrontPage = () => {
  const scrollPosition = useScrollPosition();

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
                    <VippsButton size="lg" />
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
    </>
  );
};
