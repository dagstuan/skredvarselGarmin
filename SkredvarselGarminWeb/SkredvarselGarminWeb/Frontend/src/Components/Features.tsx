import {
  Heading,
  Flex,
  Text,
  Card,
  CardBody,
  Stack,
  Image,
} from "@chakra-ui/react";
import { Feature } from "./Feature";

import glanceImage from "../assets/glance.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import timelinesImage from "../assets/timelines.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import mainTextImage from "../assets/maintext.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import problemsImage from "../assets/problems.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import offlineImage from "../assets/offline.jpg?w=800&format=webp&as=meta:width;height;src&imagetools";

export const Features = () => (
  <Flex
    py={20}
    flexDir={"column"}
    justifyContent={"center"}
    alignItems={"center"}
  >
    <Heading as="h2" size="xl" m={10}>
      Funksjoner
    </Heading>
    <Flex
      m={10}
      gap={10}
      alignItems={"flex-start"}
      justifyContent="center"
      flexWrap="wrap"
    >
      <Feature
        imgUrl={glanceImage.src}
        imgWidth={glanceImage.width}
        imgHeight={glanceImage.height}
        heading="Glance"
        text="Se tidslinje med faregrader for en enkel region sammen med andre widgets."
      />
      <Feature
        imgUrl={timelinesImage.src}
        imgWidth={timelinesImage.width}
        imgHeight={timelinesImage.height}
        heading="Tidslinjer"
        text="Tidslinjer med farenivåer over tid for dine valgte regioner."
      />
      <Feature
        imgUrl={mainTextImage.src}
        imgWidth={mainTextImage.width}
        imgHeight={mainTextImage.height}
        heading="Tekstvarsel"
        text="Tekstvarsel med nærmere informasjon om farenivået på aktuell dag."
      />
      <Feature
        imgUrl={problemsImage.src}
        imgWidth={problemsImage.width}
        imgHeight={problemsImage.height}
        heading="Skredproblemer"
        text="Visning av alle skredproblemer meldt på en gitt dag."
      />
    </Flex>

    <Card
      m={10}
      maxW={"3xl"}
      direction={{ base: "column", sm: "row" }}
      overflow="hidden"
      variant="outline"
      boxShadow={"2xl"}
    >
      <Image
        objectFit="cover"
        maxW={{ base: "100%", sm: "200px" }}
        src={offlineImage.src}
        htmlWidth={offlineImage.width}
        htmlHeight={offlineImage.height}
        alt="Skredvarsel for Garmin"
      />

      <Stack>
        <CardBody>
          <Heading size="md">Tilgjengelig uten tilkobling</Heading>

          <Text py="2">
            Appen synkroniserer snøskredvarselet for alle valgte regioner hver
            time. Og varselet er tilgjengelig selv om du er på tur uten dekning
            eller uten mobil.
          </Text>
        </CardBody>
      </Stack>
    </Card>
  </Flex>
);
