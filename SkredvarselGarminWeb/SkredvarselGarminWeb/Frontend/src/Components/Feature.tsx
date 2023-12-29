import {
  Box,
  Center,
  Heading,
  Text,
  Stack,
  useColorModeValue,
  Image,
  useBreakpointValue,
} from "@chakra-ui/react";

type FeatureProps = {
  imgUrl: string;
  imgWidth: number;
  imgHeight: number;
  heading: string;
  text: string;
};

export const Feature = ({
  imgUrl,
  imgWidth,
  imgHeight,
  heading,
  text,
}: FeatureProps) => {
  return (
    <Center py={6}>
      <Box
        maxW={useBreakpointValue({ base: "100%", sm: "3xs" })}
        bg={useColorModeValue("white", "gray.900")}
        boxShadow={"2xl"}
        rounded={"md"}
        p={6}
        overflow={"hidden"}
      >
        <Box bg={"gray.100"} mt={-6} mx={-6} mb={6} pos={"relative"}>
          <Image
            w={"full"}
            objectFit={"cover"}
            htmlWidth={imgWidth}
            htmlHeight={imgHeight}
            src={imgUrl}
            alt={text}
          />
        </Box>
        <Stack>
          <Heading
            color={useColorModeValue("gray.700", "white")}
            size={"md"}
            fontFamily={"body"}
          >
            {heading}
          </Heading>
          <Text color={"gray.600"}>{text}</Text>
        </Stack>
      </Box>
    </Center>
  );
};
