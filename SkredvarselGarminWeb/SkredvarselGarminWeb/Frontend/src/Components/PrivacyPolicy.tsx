import {
  Box,
  Center,
  Flex,
  Heading,
  Link,
  ListItem,
  Text,
  UnorderedList,
} from "@chakra-ui/react";

export const PrivacyPolicy = () => {
  return (
    <Center>
      <Flex flexDir="column" maxW="3xl" gap={10} p={10}>
        <Box>
          <Heading as="h2" size="2xl" mb={4}>
            Personvernerklæring
          </Heading>

          <Text fontSize="xl">
            Når du bruker skredvarsel.app, gir du oss tilgang til opplysninger
            om deg. Her kan du lese hvilke opplysninger vi samler inn, hvordan
            vi gjør det og hva vi bruker dem til.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Om skredvarsel.app
          </Heading>

          <Text>
            Skredvarsel.app er eid av Dag Stuan og har til hensikt å selge
            abonnement på app som viser skredvarsel på Garmin-klokker.
            Skredvarsel.app er i henhold til personopplysningsloven og EUs
            generelle personvernforordning (GDPR) behandlingsansvarlig for de
            personopplysningene som behandles av selskapet.
            <br />
            <br />
            Vi har følgende kontaktdetaljer
            <br />
            <br />
            <UnorderedList>
              <ListItem>
                Adresse: Marie Wexelsens veg 6, 7045 Trondheim
              </ListItem>
              <ListItem>Organisasjonsnummer: 926 049 690</ListItem>
            </UnorderedList>
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Hva er personopplysninger?
          </Heading>

          <Text>
            Personopplysninger er informasjon som kan knyttes til en person, for
            eksempel navn, bosted, telefonnummer, e-postadresse, IP-adresse.
            Opplysninger om hvordan du bruker kartmannen.no, for eksempel hvilke
            produkter du har sett på eller kjøpt også som personopplysninger.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Hvilke opplysninger samler vi inn?
          </Heading>

          <Text>
            Når du oppretter en bruker for å kjøpe et abonnement oppgir du
            telefonnummer til Vipps. Vi får informasjon fra Vipps og lagrer
            navn, telefonnummer og e-postadresse. Dette blir lagret slik at du
            senere kan hente status for abonnementet ditt og si det opp ved
            behov.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Informasjonskapsler
          </Heading>

          <Text>
            Det benyttes informasjonskapsler på skredvarsel.app. En
            informasjonskapsel er en liten tekstfil som sendes til nettleseren
            og plasseres på datamaskinen, nettbrettet eller mobilenheten din når
            du besøker et nettsted. Den kan brukes til å huske informasjon om
            besøkene dine og kan for eksempel brukes til å spore preferansene
            dine, for eksempel språkinnstillinger.
          </Text>
          <br />

          <Text>
            Vi bruker informasjonskapsler til å forbedre og forenkle besøket
            ditt. Vi bruker ikke informasjonskapsler til å lagre personlig
            informasjon med mindre du har gitt oss tillatelse til å gjøre det.
            Vi bruker heller ikke informasjonskapsler til å oppgi opplysninger
            til tredjeparter.
          </Text>
          <br />
          <Text>
            De fleste nettlesere godtar automatisk informasjonskapsler. Samtykke
            til bruk av informasjonskapsler anses å ha blitt gitt hvis
            nettleseren er innstilt til å godta bruk. Dette gjelder også hvis
            godkjenning er forhåndsinnstilt for nettleseren. Du kan imidlertid
            fjerne og/eller kontrollere informasjonskapsler ved å bruke
            nettleseren. Ved å bruke innstillingene i nettleseren kan du for
            eksempel fjerne alle informasjonskapsler eller velge å motta en
            melding hver gang en ny informasjonskapsel blir sendt til enheten.
            Vær oppmerksom på at det å begrense informasjonskapsler kan påvirke
            funksjonaliteten til nettstedet. Mange interaktive funksjoner som
            tilbys av nettstedet, avhenger av informasjonskapsler.
          </Text>
        </Box>
        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Hvilke informasjonskapsler benyttes?
          </Heading>

          <Text>Skredvarsel.app bruker følgende informasjonskapsler:</Text>
          <br />
          <Heading as="h4" size="md" pb={3}>
            Betaling
          </Heading>
          <UnorderedList>
            <ListItem>Vipps faste betalinger</ListItem>
            <ListItem>
              Vipps innhenter informasjon basert på deres retningslinjer som du
              kan finne i{" "}
              <Link
                color="blue"
                href="https://www.vipps.no/vilkar/cookie-og-personvern/"
              >
                Vipps personvernerklæring
              </Link>
            </ListItem>
          </UnorderedList>
        </Box>
        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Forespørsel om sletting av data
          </Heading>

          <Text>
            I samsvar med personvernlovgivningen kan du be oss om å slette dine
            personopplysninger. Dette kan gjøres ved å ta kontakt på{" "}
            <Link href="mailto:d.stuan@gmail.com">d.stuan@gmail.com</Link>.
          </Text>
        </Box>
      </Flex>
    </Center>
  );
};
