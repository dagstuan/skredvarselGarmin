import { Heading } from "./ui/heading";
import { Card, CardContent } from "./ui/card";
import { Feature } from "./Feature";

import glanceImage from "../assets/glance.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import timelinesImage from "../assets/timelines.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import mainTextImage from "../assets/maintext.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import problemsImage from "../assets/problems.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import offlineImage from "../assets/offline.jpg?w=800&format=webp&as=meta:width;height;src&imagetools";
import swedishAreasImage from "../assets/swedish_areas.png?w=800&format=webp&as=meta:width;height;src&imagetools";
import datafield2ProblemsImage from "../assets/datafield_2_problems.png?w=800&format=webp&as=meta:width;height;src&imagetools";

export const Features = () => (
  <div className="py-20 flex flex-col gap-10 md:gap-20 justify-center items-center">
    <div className="px-10 flex gap-8 md:gap-10 max-w-300 items-start justify-center flex-wrap">
      <Feature
        imgUrl={swedishAreasImage.src}
        imgWidth={swedishAreasImage.width}
        imgHeight={swedishAreasImage.height}
        heading="Norge og Sverige"
        text="Skredvarsler for alle varslingsregioner i Norge og Sverige."
      />
      <Feature
        imgUrl={datafield2ProblemsImage.src}
        imgWidth={datafield2ProblemsImage.width}
        imgHeight={datafield2ProblemsImage.height}
        heading="Datafelt"
        text="Legg til datafeltet i aktiviteten og følg varselet underveis på turen."
      />

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
        text="Tidslinjer med faregrader over tid for dine valgte regioner."
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
        heading="Skred&shy;problemer"
        text="Se alle meldte skredproblemer for dagen."
      />
    </div>

    <Card className="mx-10 max-w-3xl flex flex-col sm:flex-row overflow-hidden shadow-2xl border">
      <img
        className="object-cover w-full sm:w-50"
        src={offlineImage.src}
        width={offlineImage.width}
        height={offlineImage.height}
        alt="Skredvarsel for Garmin"
      />

      <CardContent className="p-6">
        <Heading as="h3" className="mb-2 text-xl">
          Tilgjengelig uten tilkobling
        </Heading>

        <p className="py-2 text-lg">
          Appen synkroniserer snøskredvarselet for alle valgte regioner hver
          time. Og varselet er tilgjengelig selv om du er på tur uten dekning
          eller uten mobil.
        </p>
      </CardContent>
    </Card>
  </div>
);
