import {
  Accordion,
  AccordionButton,
  AccordionIcon,
  AccordionItem,
  AccordionPanel,
  Box,
  Flex,
  Heading,
  Link,
  ListItem,
  OrderedList,
  useBreakpointValue,
  Text,
  UnorderedList,
  Image,
} from "@chakra-ui/react";

import problemsHelpImage from "../assets/problems_help.png?format=webp&imagetools";

export const FaqPage = () => {
  return (
    <Flex
      m="0 auto"
      flexDir="column"
      maxW="4xl"
      gap={10}
      py={10}
      px={useBreakpointValue({ base: 4, sm: 10 })}
    >
      <Heading as="h1" size="2xl" mb={4}>
        Ofte stilte spørsmål
      </Heading>

      <Accordion allowMultiple>
        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Hvordan installerer jeg appen?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            <OrderedList>
              <ListItem>
                Gå til{" "}
                <Link
                  href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
                  target="_blank"
                  color="blue.600"
                >
                  Connect IQ Store
                </Link>{" "}
                og last ned appen til klokken din. Det kan hende du må
                installere "Connect IQ Store"-appen til mobiltelefonen din.
              </ListItem>
              <ListItem>
                <Link
                  color="blue.600"
                  href="https://skredvarsel.app/createVippsAgreement"
                >
                  Kjøp et abonnement på appen
                </Link>
                .
              </ListItem>
              <ListItem>
                Start appen på klokka. Da bør det dukke opp en kode du skal
                skrive inn.
              </ListItem>
              <ListItem>
                Gå til{" "}
                <Link color="blue.600" href="https://skredvarsel.app/minSide">
                  Min side
                </Link>{" "}
                og skriv inn koden som står på klokka.
              </ListItem>
              <ListItem>Tusen takk! 🎉</ListItem>
            </OrderedList>
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Hva betyr symbolene i detaljvisningen?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            <Flex
              gap={4}
              flexDir={useBreakpointValue({ base: "column", sm: "row" })}
            >
              <Box flexBasis={useBreakpointValue({ base: "50%", sm: "40%" })}>
                <Image src={problemsHelpImage} />
              </Box>
              <Box flexBasis={useBreakpointValue({ base: "50%" })}>
                <Text mb={2}>Rødt markerer området som er mest utsatt.</Text>
                <OrderedList mb={2}>
                  <ListItem>
                    Himmelretninger som er mest utsatt for skredproblemet.
                  </ListItem>
                  <ListItem>Hvor i fjellet skredproblemet er.</ListItem>
                  <ListItem>
                    Høyder over havet hvor skredproblemet finnes.
                  </ListItem>
                  <ListItem>Varslet faregrad for skredproblemet.</ListItem>
                </OrderedList>
                <Text>
                  NB! Det vil alltid være lokale variasjoner, og de røde
                  områdene angir mest utsatte steder. Det vil si at
                  skredproblemet også kan være tilstede i andre områder, men det
                  er forventa at det er i mindre omfang her.
                </Text>
              </Box>
            </Flex>
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Kan jeg betale med noe annet enn Vipps?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Garmin tilbyr ikke betaling av apper i sin egen "Connect IQ Store",
            så all betaling for apper til Garmin-klokker må tas utenfor. Derfor
            må jeg selv lage betalingsløsning, og har enn så lenge valgt å kun
            tilby Vipps som betalingsløsning.
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Hvilke klokker virker appen på?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            <Text mb={4}>
              Appen virker på de fleste nyere Garmin-klokker som har
              fargeskjerm. En fullstendig oversikt kan sees på{" "}
              <Link
                href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
                target="_blank"
                color="blue.600"
              >
                Connect IQ Store
              </Link>
              . Hvis du har en klokke med støtte for musikk er det større
              sannsynlighet for at appen virker, siden de klokkene har mer
              minne.
            </Text>
            <Text mb={4}>
              Klokker hvor appen ikke virker på grunn av manglende minne:
            </Text>
            <UnorderedList>
              <ListItem>Fenix 3</ListItem>
              <ListItem>Fenix 5</ListItem>
              <ListItem>Fenix 5S</ListItem>
              <ListItem>Fenix 5X</ListItem>
              <ListItem>Fenix 6 (non-pro)</ListItem>
              <ListItem>Forerunner 635</ListItem>
              <ListItem>Forerunner 935</ListItem>
              <ListItem>Forerunner 235 (non-music)</ListItem>
              <ListItem>Vivoactive 3</ListItem>
            </UnorderedList>
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Hvorfor virker den ikke på {"["}klokken min{"]"}?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Jeg har forsøkt å få appen til å fungere på så mange klokker som
            mulig, og nye klokker legges til etterhvert. Hvis appen ikke
            fungerer på klokken din er det mest sannsynlig på grunn av
            minnebegrensninger i selve klokken. Garmin-klokker har veldig
            strenge krav til minnebruk for å opprettholde batteritiden på
            klokka.
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Ting ser rart ut på skjermen min.
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Noen Garmin-klokker med veldig liten skjerm har ikke så mye plass
            til å vise informasjon. Jeg er enda ikke helt ferdig med å få appen
            til å virke perfekt med små skjermer. Jeg har heller ikke testet med
            alle fysiske klokker, siden jeg ikke eier alle sammen. Send meg
            gjerne et bilde av hvordan det ser ut på klokken din så jeg kan
            forbedre visningen.
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Hvor kommer varslene fra?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Varslene hentes fra Snøskredvarslingen i Norge og{" "}
            <Link href="https://www.varsom.no" target="_blank" color="blue.600">
              www.varsom.no
            </Link>{" "}
            via deres åpne API som ligger{" "}
            <Link
              href="http://api.nve.no/doc/snoeskredvarsel/"
              target="_blank"
              color="blue.600"
            >
              her
            </Link>
            .
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Hvor ofte blir varslene oppdatert?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Klokka henter varslene en gang per time og lagrer de på klokka. I
            tillegg hentes de på nytt når du åpner appen dersom de er gamle.
            Hvis varslene er eldre enn 24 timer gamle vil de ikke lenger vises
            frem.
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Hvordan kommuniserer klokka med internett?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Klokka er avhengig av tilkobling til mobiltelefon med Bluetooth for
            å få hentet varsler fra internett, siden nesten ingen Garmin-klokker
            har direkte tilgang til internett selv. Hvis klokken din har
            utdaterte varsler eller slutter å vise varsler kan det være fordi
            klokka mangler tilkobling til mobil.
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Kan klokka forstyrre skredsøkeren (sender/mottaker)?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Akkurat som at en mobiltelefon kan forstyrre en skredsøker, er det
            også en viss mulighet for at en smartklokke kan forårsake
            forstyrrelser. Derfor anbefales det å slå av kommunikasjon med
            mobiltelefonen mens man går tur. En{" "}
            <Link
              href="https://arc.lib.montana.edu/snow-science/objects/ISSW14_paper_P4.13.pdf"
              color="blue.600"
              target="_blank"
            >
              forskningsartikkel
            </Link>{" "}
            fra 2014 publiserte en anbefaling om at man har klokka på motsatt
            hånd av den hånda man bruker en en skredsøker i søk-modus.
            <br />
            <br />
            For å slå av kommunikasjon med mobiltelefon underveis på turen kan
            man på de fleste Garmin-klokker konfigurere "Power mode" underveis i
            en aktivitet. Da kan man velge at "Power mode" for aktiviteten du
            bruker under topptur slår av kommunikasjon med mobil. Se
            instruksjonsboka for klokken din for å finne ut hvordan du gjør det
            på din klokke.
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Hvorfor er ikke appen gratis?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            For å få appen til å fungere med Garmin må jeg kjøre en liten
            webtjeneste som behandler varslene fra Varsom og fjerner unødvendig
            informasjon for klokkevisning. Appen koster litt penger slik at jeg
            kan holde den webtjenesten gående uten å tape penger.
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Kan jeg få se kildekoden til appen?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Det kan du! Hele appen, inkludert denne websiden, ligger åpent
            tilgjengelig på{" "}
            <Link
              href="https://github.com/dagstuan/skredvarselGarmin/"
              target="_blank"
              color="blue.600"
            >
              Github
            </Link>
            .
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Jeg fant en feil!
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Ta kontakt, så skal jeg prøve å fikse det.
          </AccordionPanel>
        </AccordionItem>

        <AccordionItem>
          <h2>
            <AccordionButton>
              <Box as="span" flex="1" textAlign="left">
                Jeg lurer fortsatt på noe. Hvordan kan jeg ta kontakt?
              </Box>
              <AccordionIcon />
            </AccordionButton>
          </h2>
          <AccordionPanel pb={4}>
            Ta kontakt på{" "}
            <Link
              href="https://www.instagram.com/dagstuan/"
              target="_blank"
              color="blue.600"
            >
              Instagram
            </Link>{" "}
            eller{" "}
            <Link
              href="mailto:d.stuan@gmail.com"
              target="_blank"
              color="blue.600"
            >
              mail
            </Link>{" "}
            hvis du fortsatt lurer på noe.
          </AccordionPanel>
        </AccordionItem>
      </Accordion>
    </Flex>
  );
};
