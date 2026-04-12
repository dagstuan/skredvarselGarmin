import { Heading } from "./ui/heading";

export const PrivacyPolicy = () => {
  return (
    <div className="m-auto flex flex-col max-w-4xl gap-10 p-10">
      <div>
        <Heading as="h2" className="mb-6 text-4xl">
          Personvernerklæring
        </Heading>

        <p className="text-xl">
          Når du bruker skredvarsel.app, gir du oss tilgang til opplysninger om
          deg. Her kan du lese hvilke opplysninger vi samler inn, hvordan vi
          gjør det og hva vi bruker dem til.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Om skredvarsel.app
        </Heading>

        <p>
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
          <ul className="list-disc list-inside">
            <li>Adresse: Marie Wexelsens veg 6, 7045 Trondheim</li>
            <li>Organisasjonsnummer: 926 049 690</li>
          </ul>
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Hva er personopplysninger?
        </Heading>

        <p>
          Personopplysninger er informasjon som kan knyttes til en person, for
          eksempel navn, bosted, telefonnummer, e-postadresse, IP-adresse.
          Opplysninger om hvordan du bruker kartmannen.no, for eksempel hvilke
          produkter du har sett på eller kjøpt også som personopplysninger.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Hvilke opplysninger samler vi inn?
        </Heading>

        <p>
          Når du oppretter en bruker for å kjøpe et abonnement oppgir du
          telefonnummer til Vipps. Vi får informasjon fra Vipps og lagrer navn,
          telefonnummer og e-postadresse. Dette blir lagret slik at du senere
          kan hente status for abonnementet ditt og si det opp ved behov.
        </p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Informasjonskapsler
        </Heading>

        <p>
          Det benyttes informasjonskapsler på skredvarsel.app. En
          informasjonskapsel er en liten tekstfil som sendes til nettleseren og
          plasseres på datamaskinen, nettbrettet eller mobilenheten din når du
          besøker et nettsted. Den kan brukes til å huske informasjon om
          besøkene dine og kan for eksempel brukes til å spore preferansene
          dine, for eksempel språkinnstillinger.
        </p>
        <br />

        <p>
          Vi bruker informasjonskapsler til å forbedre og forenkle besøket ditt.
          Vi bruker ikke informasjonskapsler til å lagre personlig informasjon
          med mindre du har gitt oss tillatelse til å gjøre det. Vi bruker
          heller ikke informasjonskapsler til å oppgi opplysninger til
          tredjeparter.
        </p>
        <br />
        <p>
          De fleste nettlesere godtar automatisk informasjonskapsler. Samtykke
          til bruk av informasjonskapsler anses å ha blitt gitt hvis nettleseren
          er innstilt til å godta bruk. Dette gjelder også hvis godkjenning er
          forhåndsinnstilt for nettleseren. Du kan imidlertid fjerne og/eller
          kontrollere informasjonskapsler ved å bruke nettleseren. Ved å bruke
          innstillingene i nettleseren kan du for eksempel fjerne alle
          informasjonskapsler eller velge å motta en melding hver gang en ny
          informasjonskapsel blir sendt til enheten. Vær oppmerksom på at det å
          begrense informasjonskapsler kan påvirke funksjonaliteten til
          nettstedet. Mange interaktive funksjoner som tilbys av nettstedet,
          avhenger av informasjonskapsler.
        </p>
      </div>
      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Hvilke informasjonskapsler benyttes?
        </Heading>

        <p>Skredvarsel.app bruker følgende informasjonskapsler:</p>
        <br />
        <Heading as="h4" className="pb-2 text-xl">
          Betaling
        </Heading>
        <ul className="list-disc list-inside">
          <li>Vipps faste betalinger</li>
          <li>
            Vipps innhenter informasjon basert på deres retningslinjer som du
            kan finne i{" "}
            <a
              className="text-blue-600 hover:underline"
              href="https://www.vipps.no/vilkar/cookie-og-personvern/"
            >
              Vipps personvernerklæring
            </a>
          </li>
        </ul>
      </div>
      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          Forespørsel om sletting av data
        </Heading>

        <p>
          I samsvar med personvernlovgivningen kan du be oss om å slette dine
          personopplysninger. Dette kan gjøres ved å ta kontakt på{" "}
          <a href="mailto:d.stuan@gmail.com" className="hover:underline">
            d.stuan@gmail.com
          </a>
          .
        </p>
      </div>
    </div>
  );
};
