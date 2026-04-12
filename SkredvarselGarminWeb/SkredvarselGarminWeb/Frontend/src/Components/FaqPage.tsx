import {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
} from "./ui/accordion";
import { Heading } from "./ui/heading";

import problemsHelpImage from "../assets/problems_help.png?format=webp&as=meta:width;height;src&imagetools";
import { useEffect, useRef } from "react";
import { useLocation } from "react-router-dom";

export const FaqPage = () => {
  const location = useLocation();

  const isVippsLoginHash = location.hash === "#vippslogin";

  const vippsLoginRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isVippsLoginHash && vippsLoginRef.current) {
      const curr = vippsLoginRef.current;
      setTimeout(() => {
        curr.scrollIntoView();
      }, 0);
    }
  }, [isVippsLoginHash]);

  const isMobile = window.innerWidth < 640;

  return (
    <div className="m-auto flex flex-col max-w-4xl gap-10 py-10 px-4 sm:px-10">
      <Heading as="h1" className="mb-4 text-4xl">
        Ofte stilte spørsmål
      </Heading>

      <Accordion multiple defaultValue={isVippsLoginHash ? ["12"] : undefined}>
        <AccordionItem value="0">
          <AccordionTrigger>Hvordan installerer jeg appen?</AccordionTrigger>
          <AccordionContent>
            <ol className="list-decimal list-inside space-y-2">
              <li>
                Gå til{" "}
                <a
                  href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-600 hover:underline"
                >
                  Connect IQ Store
                </a>{" "}
                og last ned appen til klokken din. Det kan hende du må
                installere "Connect IQ Store"-appen til mobiltelefonen din.
              </li>
              <li>
                <a
                  className="text-blue-600 hover:underline"
                  href="https://skredvarsel.app/createVippsAgreement"
                >
                  Kjøp et abonnement på appen
                </a>
                .
              </li>
              <li>
                Start appen på klokka. Da bør det dukke opp en kode du skal
                skrive inn.
              </li>
              <li>
                Gå til{" "}
                <a
                  className="text-blue-600 hover:underline"
                  href="https://skredvarsel.app/account"
                >
                  Min side
                </a>{" "}
                og skriv inn koden som står på klokka.
              </li>
              <li>Tusen takk! 🎉</li>
            </ol>
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="1">
          <AccordionTrigger>
            Hva betyr symbolene i detaljvisningen?
          </AccordionTrigger>
          <AccordionContent>
            <div className={`flex gap-4 ${isMobile ? "flex-col" : "flex-row"}`}>
              <div className={isMobile ? "w-full" : "w-2/5"}>
                <img
                  src={problemsHelpImage.src}
                  width={problemsHelpImage.width}
                  height={problemsHelpImage.height}
                  alt="Problems help"
                />
              </div>
              <div className="flex-1">
                <p className="mb-2">
                  Rødt markerer området som er mest utsatt.
                </p>
                <ol className="list-decimal list-inside mb-2 space-y-1">
                  <li>
                    Himmelretninger som er mest utsatt for skredproblemet.
                  </li>
                  <li>Hvor i fjellet skredproblemet er.</li>
                  <li>Høyder over havet hvor skredproblemet finnes.</li>
                  <li>Varslet faregrad for skredproblemet.</li>
                </ol>
                <p>
                  NB! Det vil alltid være lokale variasjoner, og de røde
                  områdene angir mest utsatte steder. Det vil si at
                  skredproblemet også kan være tilstede i andre områder, men det
                  er forventa at det er i mindre omfang her.
                </p>
              </div>
            </div>
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="2">
          <AccordionTrigger>
            Kan jeg betale med noe annet enn Vipps?
          </AccordionTrigger>
          <AccordionContent>
            Garmin tilbyr ikke betaling av apper i sin egen "Connect IQ Store",
            så all betaling for apper til Garmin-klokker må tas utenfor. Derfor
            må jeg selv lage betalingsløsning, og har enn så lenge valgt å kun
            tilby Vipps som betalingsløsning.
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="3">
          <AccordionTrigger>Hvilke klokker virker appen på?</AccordionTrigger>
          <AccordionContent>
            <p className="mb-4">
              Appen virker på de fleste nyere Garmin-klokker som har
              fargeskjerm. En fullstendig oversikt kan sees på{" "}
              <a
                href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:underline"
              >
                Connect IQ Store
              </a>
              . Hvis du har en klokke med støtte for musikk er det større
              sannsynlighet for at appen virker, siden de klokkene har mer
              minne.
            </p>
            <p className="mb-4">
              Klokker hvor appen ikke virker på grunn av manglende minne:
            </p>
            <ul className="list-disc list-inside">
              <li>Fenix 3</li>
              <li>Fenix 5</li>
              <li>Fenix 5S</li>
              <li>Fenix 5X</li>
              <li>Fenix 6 (non-pro)</li>
              <li>Forerunner 635</li>
              <li>Forerunner 935</li>
              <li>Forerunner 235 (non-music)</li>
              <li>Vivoactive 3</li>
            </ul>
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="4">
          <AccordionTrigger>
            Hvorfor virker den ikke på [klokken min]?
          </AccordionTrigger>
          <AccordionContent>
            Jeg har forsøkt å få appen til å fungere på så mange klokker som
            mulig, og nye klokker legges til etterhvert. Hvis appen ikke
            fungerer på klokken din er det mest sannsynlig på grunn av
            minnebegrensninger i selve klokken. Garmin-klokker har veldig
            strenge krav til minnebruk for å opprettholde batteritiden på
            klokka.
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="5">
          <AccordionTrigger>Ting ser rart ut på skjermen min.</AccordionTrigger>
          <AccordionContent>
            Noen Garmin-klokker med veldig liten skjerm har ikke så mye plass
            til å vise informasjon. Jeg er enda ikke helt ferdig med å få appen
            til å virke perfekt med små skjermer. Jeg har heller ikke testet med
            alle fysiske klokker, siden jeg ikke eier alle sammen. Send meg
            gjerne et bilde av hvordan det ser ut på klokken din så jeg kan
            forbedre visningen.
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="6">
          <AccordionTrigger>Hvor kommer varslene fra?</AccordionTrigger>
          <AccordionContent>
            Varslene hentes fra Snøskredvarslingen i Norge og{" "}
            <a
              href="https://www.varsom.no"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              www.varsom.no
            </a>{" "}
            via deres åpne API som ligger{" "}
            <a
              href="http://api.nve.no/doc/snoeskredvarsel/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              her
            </a>
            .
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="7">
          <AccordionTrigger>
            Hvor ofte blir varslene oppdatert?
          </AccordionTrigger>
          <AccordionContent>
            Klokka henter varslene en gang per time og lagrer de på klokka. I
            tillegg hentes de på nytt når du åpner appen dersom de er gamle.
            Hvis varslene er eldre enn 24 timer gamle vil de ikke lenger vises
            frem.
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="8">
          <AccordionTrigger>
            Hvordan kommuniserer klokka med internett?
          </AccordionTrigger>
          <AccordionContent>
            Klokka er avhengig av tilkobling til mobiltelefon med Bluetooth for
            å få hentet varsler fra internett, siden nesten ingen Garmin-klokker
            har direkte tilgang til internett selv. Hvis klokken din har
            utdaterte varsler eller slutter å vise varsler kan det være fordi
            klokka mangler tilkobling til mobil.
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="9">
          <AccordionTrigger>
            Kan klokka forstyrre skredsøkeren (sender/mottaker)?
          </AccordionTrigger>
          <AccordionContent>
            Akkurat som at en mobiltelefon kan forstyrre en skredsøker, er det
            også en viss mulighet for at en smartklokke kan forårsake
            forstyrrelser. Derfor anbefales det å slå av kommunikasjon med
            mobiltelefonen mens man går tur. En{" "}
            <a
              href="https://arc.lib.montana.edu/snow-science/objects/ISSW14_paper_P4.13.pdf"
              className="text-blue-600 hover:underline"
              target="_blank"
              rel="noopener noreferrer"
            >
              forskningsartikkel
            </a>{" "}
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
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="10">
          <AccordionTrigger>Hvorfor er ikke appen gratis?</AccordionTrigger>
          <AccordionContent>
            For å få appen til å fungere med Garmin må jeg kjøre en liten
            webtjeneste som behandler varslene fra Varsom og fjerner unødvendig
            informasjon for klokkevisning. Appen koster litt penger slik at jeg
            kan holde den webtjenesten gående uten å tape penger.
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="11">
          <AccordionTrigger>
            Kan jeg få se kildekoden til appen?
          </AccordionTrigger>
          <AccordionContent>
            Det kan du! Hele appen, inkludert denne websiden, ligger åpent
            tilgjengelig på{" "}
            <a
              href="https://github.com/dagstuan/skredvarselGarmin/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              Github
            </a>
            .
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="12" ref={vippsLoginRef}>
          <AccordionTrigger>
            Hvorfor kan jeg ikke logge inn med Vipps lenger?
          </AccordionTrigger>
          <AccordionContent>
            Vipps har endret vilkårene sine, og "Logg inn med Vipps" er nå et{" "}
            <a
              href="https://vippsmobilepay.com/no/priser/logg-inn"
              className="hover:underline"
            >
              betalt produkt.
            </a>{" "}
            Jeg syns prisen Vipps har valgt å ta er urimelig høy, og har derfor
            erstattet "Logg inn med Vipps" med innlogging med e-post. Hvis du
            har problemer med å logge inn, ikke nøl med å ta kontakt!
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="13">
          <AccordionTrigger>Jeg fant en feil!</AccordionTrigger>
          <AccordionContent>
            Ta kontakt, så skal jeg prøve å fikse det.
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="14">
          <AccordionTrigger>
            Jeg lurer fortsatt på noe. Hvordan kan jeg ta kontakt?
          </AccordionTrigger>
          <AccordionContent>
            Ta kontakt på{" "}
            <a
              href="https://www.instagram.com/dagstuan/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              Instagram
            </a>{" "}
            eller{" "}
            <a
              href="mailto:d.stuan@gmail.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              mail
            </a>{" "}
            hvis du fortsatt lurer på noe.
          </AccordionContent>
        </AccordionItem>
      </Accordion>
    </div>
  );
};
