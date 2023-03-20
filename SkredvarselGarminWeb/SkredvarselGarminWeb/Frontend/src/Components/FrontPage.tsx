import {
  Flex,
  VStack,
  useBreakpointValue,
  Stack,
  Text,
  Wrap,
  WrapItem,
} from "@chakra-ui/react";
import { Features } from "./Features";

import bg from "../assets/bg.jpg";
import { MyPage } from "./MyPage/MyPage";
import { VippsButton } from "./VippsButton";
import { CiqStoreButton } from "./CiqStoreButton";

export const FrontPage = () => {
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
        <VStack
          w={"full"}
          flex={"1 1 100%"}
          justify={"center"}
          px={useBreakpointValue({ base: 4, md: 8 })}
          bgGradient={"linear(135deg, blackAlpha.700, transparent)"}
        >
          <Stack pb="42px" maxW={"4xl"} align={"flex-start"} spacing={6}>
            <Text
              color={"white"}
              fontWeight={700}
              lineHeight={1.2}
              fontSize={useBreakpointValue({ base: "3xl", md: "4xl" })}
            >
              Skredvarsel for Garmin-klokker. Oppdatert og tilgjengelig mens du
              er på tur.
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
                <CiqStoreButton />
              </WrapItem>
              <WrapItem>
                <VippsButton />
              </WrapItem>
            </Wrap>
          </Stack>
        </VStack>
      </Flex>
      <Features />
      <MyPage />
    </>
  );
};
