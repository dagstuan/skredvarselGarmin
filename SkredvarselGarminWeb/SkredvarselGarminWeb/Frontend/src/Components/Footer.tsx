import { ReactNode } from "react";
import { Container } from "./ui/container";
import { Link as RouterLink } from "react-router-dom";

const ListHeader = ({ children }: { children: ReactNode }) => {
  return <div className="font-medium text-lg mb-2">{children}</div>;
};

export const Footer = () => {
  return (
    <div className="bg-gray-50 text-gray-700">
      <Container maxW="6xl" className="pt-10">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-8">
          <div className="space-y-6 md:col-span-2">
            <div>Dag Stuan</div>
            <p className="text-sm">
              Varsler fra Snøskredvarslingen i Norge og{" "}
              <a href="https://www.varsom.no" className="underline hover:no-underline">
                www.varsom.no
              </a>
            </p>
            <p className="text-sm">
              Ikoner fra{" "}
              <a href="https://www.avalanches.org/" className="underline hover:no-underline">
                European Avalanche Warning Services.
              </a>
            </p>
          </div>
          <div className="flex flex-col items-start space-y-2">
            <ListHeader>Om</ListHeader>
            <RouterLink to="faq" className="hover:underline">
              Ofte stilte spørsmål
            </RouterLink>
            <RouterLink to="privacy" className="hover:underline">
              Personvern og informasjonskapsler
            </RouterLink>
            <RouterLink to="salesconditions" className="hover:underline">
              Salgsbetingelser
            </RouterLink>
            <a href="https://github.com/dagstuan/skredvarselGarmin/" className="hover:underline">
              Kildekode
            </a>
          </div>
          <div className="flex flex-col items-start space-y-2">
            <ListHeader>Sosiale medier</ListHeader>
            <a href="https://www.instagram.com/dagstuan/" className="hover:underline">
              Instagram
            </a>
            <a href="https://github.com/dagstuan/" className="hover:underline">
              Github
            </a>
          </div>
        </div>
      </Container>
      <Container maxW="6xl" className="py-10">
        <p className="text-xs max-w-3xl">
          Bruk varslene og datagrunnlaget på eget ansvar. Det kan forekomme feil
          og mangler. Varselet er et hjelpemiddel, ikke en fasit. Gjør alltid
          egne vurderinger. Tilpass egen risiko i utsatte områder ved å velge
          hvor, når og hvordan du ferdes. Varslene er regionale og basert på
          tilgjengelige observasjoner og værprognoser. Forholdene kan være
          komplekse og avvike fra det som er varslet. Verken NVE eller Dag Stuan
          gir garantier for informasjonens aktualitet og tar ikke ansvar for at
          data kan gi feil eller villedende informasjon.
        </p>
      </Container>
    </div>
  );
};
