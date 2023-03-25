import { ReactNode } from "react";

import {
  Box,
  Container,
  Link,
  SimpleGrid,
  Stack,
  Text,
  useColorModeValue,
} from "@chakra-ui/react";

import { Link as RouterLink } from "react-router-dom";

const ListHeader = ({ children }: { children: ReactNode }) => {
  return (
    <Text fontWeight={"500"} fontSize={"lg"} mb={2}>
      {children}
    </Text>
  );
};

export const Footer = () => {
  return (
    <Box
      bg={useColorModeValue("gray.50", "gray.900")}
      color={useColorModeValue("gray.700", "gray.200")}
    >
      <Container as={Stack} maxW={"6xl"} pt={10}>
        <SimpleGrid
          templateColumns={{ sm: "1fr 1fr", md: "2fr 1fr 1fr 1fr 1fr" }}
          spacing={8}
        >
          <Stack spacing={6}>
            <Box>
              <Box>Dag Stuan</Box>
            </Box>
            <Text fontSize={"sm"}>
              Varsler fra Snøskredvarslingen i Norge og{" "}
              <Link href="https://www.varsom.no">www.varsom.no</Link>
            </Text>
            <Text fontSize={"sm"}>
              Ikoner fra{" "}
              <Link href="https://www.avalanches.org/">
                European Avalance Warning Services.
              </Link>
            </Text>
          </Stack>
          <Stack align={"flex-start"}>
            <ListHeader>Om</ListHeader>
            <Link as={RouterLink} to="faq">
              Ofte stilte spørsmål
            </Link>
            <Link as={RouterLink} to="personvern">
              Personvern og informasjonskapsler
            </Link>
            <Link as={RouterLink} to="salgsbetingelser">
              Salgsbetingelser
            </Link>
            <Link href="https://github.com/dagstuan/skredvarselGarmin/">
              Kildekode
            </Link>
          </Stack>
          <Stack align={"flex-start"}>
            <ListHeader>Sosiale medier</ListHeader>
            <Link href="https://www.instagram.com/dagstuan/">Instagram</Link>
            <Link href="https://github.com/dagstuan/">Github</Link>
          </Stack>
        </SimpleGrid>
      </Container>
      <Container maxW={"6xl"} py={10}>
        <Text fontSize="xs" maxW="3xl">
          Bruk varslene og datagrunnlaget på eget ansvar. Det kan forekomme feil
          og mangler. Varselet er et hjelpemiddel, ikke en fasit. Gjør alltid
          egne vurderinger. Tilpass egen risiko i utsatte områder ved å velge
          hvor, når og hvordan du ferdes. Varslene er regionale og basert på
          tilgjengelige observasjoner og værprognoser. Forholdene kan være
          komplekse og avvike fra det som er varslet. Verken NVE eller Dag Stuan
          gir garantier for informasjonens aktualitet og tar ikke ansvar for at
          data kan gi feil eller villedende informasjon.
        </Text>
      </Container>
    </Box>
  );
};
