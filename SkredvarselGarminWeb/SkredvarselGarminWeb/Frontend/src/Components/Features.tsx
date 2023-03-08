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

import glanceImage from "../assets/glance.png";
import timelinesImage from "../assets/timelines.png";
import mainTextImage from "../assets/maintext.png";
import problemsImage from "../assets/problems.png";
import offlineImage from "../assets/offline.jpg";

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
    <Flex m={5} maxW={"5xl"} alignItems={"flex-start"} gap={10}>
      <Feature
        imgUrl={glanceImage}
        heading="Glance"
        text="Se tidslinje med faregrader for en enkel region sammen med andre widgets."
      />
      <Feature
        imgUrl={timelinesImage}
        heading="Tidslinjer"
        text="Tidslinjer med farenivåer over tid for dine valgte regioner."
      />
      <Feature
        imgUrl={mainTextImage}
        heading="Tekstvarsel"
        text="Tekstvarsel med nærmere informasjon om farenivået på aktuell dag."
      />
      <Feature
        imgUrl={problemsImage}
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
    >
      <Image
        objectFit="cover"
        maxW={{ base: "100%", sm: "200px" }}
        src={offlineImage}
        alt="Caffe Latte"
      />

      <Stack>
        <CardBody>
          <Heading size="md">Offline-modus</Heading>

          <Text py="2">
            Appen synkroniserer skredvarselet for alle valgte regioner hver
            time. Og varselet er tilgjengelig selv om du er på tur uten dekning
            eller uten mobil.
          </Text>
        </CardBody>
      </Stack>
    </Card>
  </Flex>
);
