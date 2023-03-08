import {
  Flex,
  VStack,
  useBreakpointValue,
  Stack,
  Button,
  Text,
} from "@chakra-ui/react";
import { Features } from "./Features";

import bg from "../assets/bg.jpg";

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
          bgGradient={"linear(to-r, blackAlpha.600, transparent)"}
        >
          <Stack maxW={"4xl"} align={"flex-start"} spacing={6}>
            <Text
              color={"white"}
              fontWeight={700}
              lineHeight={1.2}
              fontSize={useBreakpointValue({ base: "3xl", md: "4xl" })}
            >
              Skredvarsel for Garmin-klokker. Oppdatert og tilgjengelig offline
              mens du er på tur.
            </Text>
            <Stack direction={"row"} align={"center"} justify={"center"}>
              <Text color={"white"} fontSize={"3xl"} fontWeight={800}>
                30 kr
              </Text>
              <Text fontSize={"xl"} color={"white"}>
                /år
              </Text>
            </Stack>
            <Stack direction={"row"}>
              <Button
                bg={"blue.400"}
                rounded={"full"}
                color={"white"}
                _hover={{ bg: "blue.500" }}
              >
                Kjøp abonnement
              </Button>
            </Stack>
          </Stack>
        </VStack>
      </Flex>
      <Features />
    </>
  );
};
