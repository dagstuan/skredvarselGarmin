import { Box, Center, Flex, Heading, Text } from "@chakra-ui/react";

export const SalesConditions = () => {
  return (
    <Center>
      <Flex flexDir="column" gap={10} maxW="3xl" p={10}>
        <Box>
          <Heading as="h2" size="2xl" pb={4}>
            Salgsbetingelser
          </Heading>

          <Text fontSize="xl">
            Disse salgsbetingelsene gjelder for salg av varer og tjenester til
            forbrukere av Skredvarsel for Garmin. Med forbruker menes en fysisk
            person som ikke hovedsakelig handler som ledd i næringsvirksomhet.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Selger
          </Heading>

          <Text>
            Dag Stuan
            <br /> Organisasjonsnummer: 926 049 690
            <br /> Adresse: Marie Wexelsens veg 6, 7045 Trondheim
            <br /> Heretter også omtalt som «vi», «oss» eller «skredvarsel.app».
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Kjøper
          </Heading>

          <Text>
            Er den personen som er oppgitt som kjøper i bestillingen (heretter
            også omtalt som «du», «din» eller «deg»).
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Betaling
          </Heading>

          <Text>
            Vipps brukes som betalingsmetode. Abonnementsbetaling vil bli
            fakturert automatisk ved starten av den månedlige eller årlige
            perioden, avhengig av hvilken betalingsperiode du velger. Betaling
            fornyes automatisk inntil abonnementet ditt nedgraderes eller
            avsluttes. Du kan kansellere abonnementet ditt når som helst, som
            beskrevet nedenfor.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Avgifter
          </Heading>

          <Text>
            For å få tilgang til applikasjonen på klokka, blir du pålagt å
            betale abonnementsavgift. Abonnementsavgift kan betales på månedlig
            eller årlig basis. Abonnementsavgiften betales på forhånd. Hvis du
            bytter fra månedlig til årlig abonnement vil årspris tre i kraft ved
            begynnelsen av neste faktureringsdato. Du godtar å betale
            abonnementsavgift i forbindelse med kontoen din på skredvarsel.app,
            enten på engangs- eller abonnement basis. Skredvarsel.app
            forbeholder seg retten til å øke abonnementsavgiftene, eventuelle
            tilknyttede skatter, eller å innføre nye avgifter når som helst med
            rimelig forhåndsvarsel.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Automatisk fornyelse av abonnement
          </Heading>

          <Text>
            Abonnementsavgifter vil bli fakturert automatisk ved starten av den
            månedlige eller årlige perioden, avhengig av hva som er aktuelt.
            Disse avgiftene fornyes automatisk inntil abonnementet ditt
            nedgraderes eller avsluttes. Abonnementsavgiften din vil være den
            samme som de første kostnadene dine med mindre du får beskjed om noe
            annet på forhånd. Du kan kansellere abonnementet ditt når som helst,
            som beskrevet nedenfor.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Levering
          </Heading>

          <Text>
            Etter godkjent betaling vil du få tilgang til data på klokken.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Kansellering av abonnement
          </Heading>

          <Text>
            Du kan kansellere abonnementet ditt ved å gå til «Konto»-siden og
            velge «Avslutt». Kanselleringen av et abonnement trer i kraft ved
            slutten av gjeldende faktureringsperiode. Du kan fornye abonnementet
            ditt når som helst uten å åpne en ny konto, selv om
            abonnementsavgiftene kan ha økt. Du kan slette kontoen din når som
            helst.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Angrerett
          </Heading>

          <Text>
            Alle abonnementer har 14 dagers angrerett. Vær oppmerksom på at
            angreretten kun gjelder nye kjøp, og ikke ved automatisk fornyelse
            av ditt abonnement. For å angre ditt kjøp, send en e-post til:
            d.stuan@gmail.com Skriv gjerne også hvorfor du ønsker å angre kjøpet
            ditt. Dette hjelper oss å forbedre tjenesten vår i fremtiden. Hvis
            du benytter deg av angreretten, vil du få tilbakebetalt tjenestens
            verdi ved kjøpstidspunktet. Beløpet vil tilbakeføres direkte til den
            Vipps-kontoen du benyttet ved kjøp.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Konfliktløsning
          </Heading>

          <Text>
            Klager rettes til selger innen rimelig tid. Partene skal forsøke å
            løse eventuelle tvister i minnelighet. Dersom dette ikke lykkes, kan
            kjøperen ta kontakt med Forbrukerrådet for mekling. Forbrukerrådet
            er tilgjengelig på telefon 23 400 500 eller www.forbrukerradet.no.
          </Text>
        </Box>

        <Box>
          <Heading as="h3" size="lg" pb={4}>
            Mangel ved varen - kjøperens rettigheter og reklamasjonsfrist
          </Heading>

          <Text>
            Hvis det foreligger en mangel ved varen må kjøper innen rimelig tid
            etter at den ble oppdaget eller burde ha blitt oppdaget, gi selger
            melding om at han eller hun vil påberope seg mangelen. Kjøper har
            alltid reklamert tidsnok dersom det skjer innen 2 mnd. fra mangelen
            ble oppdaget eller burde blitt oppdaget. Reklamasjon kan skje senest
            to år etter at kjøper overtok varen. For å reklamere på ditt kjøp,
            send en e-post til: d.stuan@gmail.com med beskrivelse av hva som er
            mangelfullt med varen.
          </Text>
        </Box>
      </Flex>
    </Center>
  );
};
