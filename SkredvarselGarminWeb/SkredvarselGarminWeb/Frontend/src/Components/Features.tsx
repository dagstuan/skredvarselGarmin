import { Heading } from "./ui/heading";
import { Card, CardContent } from "./ui/card";
import { Feature } from "./Feature";
import { useTranslation } from "react-i18next";

import glanceImage from "../assets/glance.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import timelinesImage from "../assets/timelines.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import mainTextImage from "../assets/maintext.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import problemsImage from "../assets/problems.png?format=webp&quality=60&as=meta:width;height;src&imagetools";
import offlineImage from "../assets/offline.jpg?w=800&format=webp&as=meta:width;height;src&imagetools";
import swedishAreasImage from "../assets/swedish_areas.png?w=800&format=webp&as=meta:width;height;src&imagetools";
import datafield2ProblemsImage from "../assets/datafield_2_problems.png?w=800&format=webp&as=meta:width;height;src&imagetools";

export const Features = () => {
  const { t } = useTranslation();

  return (
    <div className="py-20 flex flex-col gap-10 md:gap-20 justify-center items-center">
      <div className="px-10 flex gap-8 md:gap-10 max-w-300 items-start justify-center flex-wrap">
        <Feature
          imgUrl={swedishAreasImage.src}
          imgWidth={swedishAreasImage.width}
          imgHeight={swedishAreasImage.height}
          heading={t(($) => $.features.norwayAndSweden.heading)}
          text={t(($) => $.features.norwayAndSweden.text)}
        />
        <Feature
          imgUrl={datafield2ProblemsImage.src}
          imgWidth={datafield2ProblemsImage.width}
          imgHeight={datafield2ProblemsImage.height}
          heading={t(($) => $.features.dataField.heading)}
          text={t(($) => $.features.dataField.text)}
        />

        <Feature
          imgUrl={glanceImage.src}
          imgWidth={glanceImage.width}
          imgHeight={glanceImage.height}
          heading={t(($) => $.features.glance.heading)}
          text={t(($) => $.features.glance.text)}
        />
        <Feature
          imgUrl={timelinesImage.src}
          imgWidth={timelinesImage.width}
          imgHeight={timelinesImage.height}
          heading={t(($) => $.features.timelines.heading)}
          text={t(($) => $.features.timelines.text)}
        />
        <Feature
          imgUrl={mainTextImage.src}
          imgWidth={mainTextImage.width}
          imgHeight={mainTextImage.height}
          heading={t(($) => $.features.textForecast.heading)}
          text={t(($) => $.features.textForecast.text)}
        />
        <Feature
          imgUrl={problemsImage.src}
          imgWidth={problemsImage.width}
          imgHeight={problemsImage.height}
          heading={t(($) => $.features.avalancheProblems.heading)}
          text={t(($) => $.features.avalancheProblems.text)}
        />
      </div>

      <Card className="mx-10 max-w-3xl flex flex-col sm:flex-row overflow-hidden shadow-2xl border">
        <img
          className="object-cover w-full sm:w-50"
          src={offlineImage.src}
          width={offlineImage.width}
          height={offlineImage.height}
          alt={t(($) => $.features.offline.alt)}
        />

        <CardContent className="p-6">
          <Heading as="h3" className="mb-2 text-xl">
            {t(($) => $.features.offline.heading)}
          </Heading>

          <p className="py-2 text-lg">{t(($) => $.features.offline.text)}</p>
        </CardContent>
      </Card>
    </div>
  );
};
