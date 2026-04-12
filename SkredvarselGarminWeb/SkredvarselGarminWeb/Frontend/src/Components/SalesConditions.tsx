import { Heading } from "./ui/heading";

export const SalesConditions = () => {
  return (
    <div className="m-auto flex flex-col gap-10 max-w-4xl p-10">
      <div>
        <Heading as="h2" className="pb-4 text-4xl">
          Salgsbetingelser
        </Heading>

        <p className="text-xl">
          Disse salgsbetingelsene gjelder for salg av varer og tjenester til
          forbrukere av Skredvarsel for Garmin. Med forbruker menes en fysisk
          person som ikke hovedsakelig handler som ledd i næringsvirksomhet.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Selger
        </Heading>

        <p>
          Dag Stuan
          <br /> Organisasjonsnummer: 926 049 690
          <br /> Adresse: Marie Wexelsens veg 6, 7045 Trondheim
          <br /> Heretter også omtalt som «vi», «oss» eller «skredvarsel.app».
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Kjøper
        </Heading>

        <p>
          Er den personen som er oppgitt som kjøper i bestillingen (heretter
          også omtalt som «du», «din» eller «deg»).
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Betaling
        </Heading>

        <p>
          Vipps brukes som betalingsmetode. Abonnementsbetaling vil bli
          fakturert automatisk ved starten av den månedlige eller årlige
          perioden, avhengig av hvilken betalingsperiode du velger. Betaling
          fornyes automatisk inntil abonnementet ditt nedgraderes eller
          avsluttes. Du kan kansellere abonnementet ditt når som helst, som
          beskrevet nedenfor.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Avgifter
        </Heading>

        <p>
          For å få tilgang til applikasjonen på klokka, blir du pålagt å betale
          abonnementsavgift. Abonnementsavgift kan betales på månedlig eller
          årlig basis. Abonnementsavgiften betales på forhånd. Hvis du bytter
          fra månedlig til årlig abonnement vil årspris tre i kraft ved
          begynnelsen av neste faktureringsdato. Du godtar å betale
          abonnementsavgift i forbindelse med kontoen din på skredvarsel.app,
          enten på engangs- eller abonnement basis. Skredvarsel.app forbeholder
          seg retten til å øke abonnementsavgiftene, eventuelle tilknyttede
          skatter, eller å innføre nye avgifter når som helst med rimelig
          forhåndsvarsel.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Automatisk fornyelse av abonnement
        </Heading>

        <p>
          Abonnementsavgifter vil bli fakturert automatisk ved starten av den
          månedlige eller årlige perioden, avhengig av hva som er aktuelt. Disse
          avgiftene fornyes automatisk inntil abonnementet ditt nedgraderes
          eller avsluttes. Abonnementsavgiften din vil være den samme som de
          første kostnadene dine med mindre du får beskjed om noe annet på
          forhånd. Du kan kansellere abonnementet ditt når som helst, som
          beskrevet nedenfor.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Levering
        </Heading>

        <p>Etter godkjent betaling vil du få tilgang til data på klokken.</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Kansellering av abonnement
        </Heading>

        <p>
          Du kan kansellere abonnementet ditt ved å gå til «Konto»-siden og
          velge «Avslutt». Kanselleringen av et abonnement trer i kraft ved
          slutten av gjeldende faktureringsperiode. Du kan fornye abonnementet
          ditt når som helst uten å åpne en ny konto, selv om
          abonnementsavgiftene kan ha økt. Du kan slette kontoen din når som
          helst.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Angrerett
        </Heading>

        <p>
          Alle abonnementer har 14 dagers angrerett. Vær oppmerksom på at
          angreretten kun gjelder nye kjøp, og ikke ved automatisk fornyelse av
          ditt abonnement. For å angre ditt kjøp, send en e-post til:
          d.stuan@gmail.com Skriv gjerne også hvorfor du ønsker å angre kjøpet
          ditt. Dette hjelper oss å forbedre tjenesten vår i fremtiden. Hvis du
          benytter deg av angreretten, vil du få tilbakebetalt tjenestens verdi
          ved kjøpstidspunktet. Beløpet vil tilbakeføres direkte til den
          Vipps-kontoen du benyttet ved kjøp.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Konfliktløsning
        </Heading>

        <p>
          Klager rettes til selger innen rimelig tid. Partene skal forsøke å
          løse eventuelle tvister i minnelighet. Dersom dette ikke lykkes, kan
          kjøperen ta kontakt med Forbrukerrådet for mekling. Forbrukerrådet er
          tilgjengelig på telefon 23 400 500 eller www.forbrukerradet.no.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Mangel ved varen - kjøperens rettigheter og reklamasjonsfrist
        </Heading>

        <p>
          Hvis det foreligger en mangel ved varen må kjøper innen rimelig tid
          etter at den ble oppdaget eller burde ha blitt oppdaget, gi selger
          melding om at han eller hun vil påberope seg mangelen. Kjøper har
          alltid reklamert tidsnok dersom det skjer innen 2 mnd. fra mangelen
          ble oppdaget eller burde blitt oppdaget. Reklamasjon kan skje senest
          to år etter at kjøper overtok varen. For å reklamere på ditt kjøp,
          send en e-post til: d.stuan@gmail.com med beskrivelse av hva som er
          mangelfullt med varen.
        </p>
      </div>
    </div>
  );
};
