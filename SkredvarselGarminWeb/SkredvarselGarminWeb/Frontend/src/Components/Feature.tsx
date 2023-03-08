import {
  Box,
  Center,
  Heading,
  Text,
  Stack,
  useColorModeValue,
  Image,
} from "@chakra-ui/react";

type FeatureProps = {
  imgUrl: string;
  heading: string;
  text: string;
};

export const Feature = ({ imgUrl, heading, text }: FeatureProps) => {
  return (
    <Center py={6}>
      <Box
        maxW={"445px"}
        w={"full"}
        bg={useColorModeValue("white", "gray.900")}
        boxShadow={"2xl"}
        rounded={"md"}
        p={6}
        overflow={"hidden"}
      >
        <Box
          h={"310px"}
          bg={"gray.100"}
          mt={-6}
          mx={-6}
          mb={6}
          pos={"relative"}
        >
          <Image w={"full"} h={"310px"} objectFit={"cover"} src={imgUrl} />
        </Box>
        <Stack>
          <Heading
            color={useColorModeValue("gray.700", "white")}
            size={"md"}
            fontFamily={"body"}
          >
            {heading}
          </Heading>
          <Text color={"gray.500"}>{text}</Text>
        </Stack>
      </Box>
    </Center>
  );
};
