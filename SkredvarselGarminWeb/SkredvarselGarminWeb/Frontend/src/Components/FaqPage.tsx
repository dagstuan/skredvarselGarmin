import {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
} from "./ui/accordion";
import { Heading } from "./ui/heading";
import { useTranslation } from "react-i18next";

import problemsHelpImage from "../assets/problems_help.png?format=webp&as=meta:width;height;src&imagetools";
import { useEffect, useRef } from "react";
import { useLocation } from "react-router-dom";

const unsupportedWatchModels = [
  "Fenix 3",
  "Fenix 5",
  "Fenix 5S",
  "Fenix 5X",
  "Fenix 6 (non-pro)",
  "Forerunner 635",
  "Forerunner 935",
  "Forerunner 235 (non-music)",
  "Vivoactive 3",
] as const;

export const FaqPage = () => {
  const { t } = useTranslation();
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
        {t(($) => $.faq.title)}
      </Heading>

      <Accordion multiple defaultValue={isVippsLoginHash ? ["12"] : undefined}>
        <AccordionItem value="0">
          <AccordionTrigger>
            {t(($) => $.faq.items.installApp.question)}
          </AccordionTrigger>
          <AccordionContent>
            <ol className="list-decimal list-inside space-y-2">
              <li>
                {t(($) => $.faq.items.installApp.step1Before)}
                <a
                  href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-600 hover:underline"
                >
                  {t(($) => $.faq.items.installApp.step1LinkLabel)}
                </a>{" "}
                {t(($) => $.faq.items.installApp.step1After)}
              </li>
              <li>
                <a
                  className="text-blue-600 hover:underline"
                  href="https://skredvarsel.app/createVippsAgreement"
                >
                  {t(($) => $.faq.items.installApp.step2LinkLabel)}
                </a>
                .
              </li>
              <li>{t(($) => $.faq.items.installApp.step3)}</li>
              <li>
                {t(($) => $.faq.items.installApp.step4Before)}
                <a
                  className="text-blue-600 hover:underline"
                  href="https://skredvarsel.app/account"
                >
                  {t(($) => $.faq.items.installApp.step4LinkLabel)}
                </a>{" "}
                {t(($) => $.faq.items.installApp.step4After)}
              </li>
              <li>
                {t(($) => $.faq.items.installApp.step5)} 🎉
              </li>
            </ol>
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="1">
          <AccordionTrigger>
            {t(($) => $.faq.items.detailSymbols.question)}
          </AccordionTrigger>
          <AccordionContent>
            <div className={`flex gap-4 ${isMobile ? "flex-col" : "flex-row"}`}>
              <div className={isMobile ? "w-full" : "w-2/5"}>
                <img
                  src={problemsHelpImage.src}
                  width={problemsHelpImage.width}
                  height={problemsHelpImage.height}
                  alt={t(($) => $.faq.problemsHelpAlt)}
                />
              </div>
              <div className="flex-1">
                <p className="mb-2">{t(($) => $.faq.items.detailSymbols.intro)}</p>
                <ol className="list-decimal list-inside mb-2 space-y-1">
                  <li>{t(($) => $.faq.items.detailSymbols.point1)}</li>
                  <li>{t(($) => $.faq.items.detailSymbols.point2)}</li>
                  <li>{t(($) => $.faq.items.detailSymbols.point3)}</li>
                  <li>{t(($) => $.faq.items.detailSymbols.point4)}</li>
                </ol>
                <p>{t(($) => $.faq.items.detailSymbols.note)}</p>
              </div>
            </div>
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="2">
          <AccordionTrigger>
            {t(($) => $.faq.items.paymentMethods.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.paymentMethods.answer)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="3">
          <AccordionTrigger>
            {t(($) => $.faq.items.compatibleWatches.question)}
          </AccordionTrigger>
          <AccordionContent>
            <p className="mb-4">
              {t(($) => $.faq.items.compatibleWatches.introBefore)}
              <a
                href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:underline"
              >
                {t(($) => $.faq.items.compatibleWatches.introLinkLabel)}
              </a>
              {t(($) => $.faq.items.compatibleWatches.introAfter)}
            </p>
            <p className="mb-4">
              {t(($) => $.faq.items.compatibleWatches.unsupportedHeading)}
            </p>
            <ul className="list-disc list-inside">
              {unsupportedWatchModels.map((model) => (
                <li key={model}>{model}</li>
              ))}
            </ul>
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="4">
          <AccordionTrigger>
            {t(($) => $.faq.items.whyNotMyWatch.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.whyNotMyWatch.answer)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="5">
          <AccordionTrigger>
            {t(($) => $.faq.items.weirdLayout.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.weirdLayout.answer)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="6">
          <AccordionTrigger>{t(($) => $.faq.items.sources.question)}</AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.sources.beforeVarsom)}
            <a
              href="https://www.varsom.no"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              {t(($) => $.faq.items.sources.varsomLinkLabel)}
            </a>{" "}
            {t(($) => $.faq.items.sources.betweenLinks)}
            <a
              href="http://api.nve.no/doc/snoeskredvarsel/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              {t(($) => $.faq.items.sources.apiLinkLabel)}
            </a>
            {t(($) => $.faq.items.sources.afterApi)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="7">
          <AccordionTrigger>
            {t(($) => $.faq.items.updateFrequency.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.updateFrequency.answer)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="8">
          <AccordionTrigger>
            {t(($) => $.faq.items.internetConnection.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.internetConnection.answer)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="9">
          <AccordionTrigger>
            {t(($) => $.faq.items.beaconInterference.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.beaconInterference.paragraph1Before)}
            <a
              href="https://arc.lib.montana.edu/snow-science/objects/ISSW14_paper_P4.13.pdf"
              className="text-blue-600 hover:underline"
              target="_blank"
              rel="noopener noreferrer"
            >
              {t(($) => $.faq.items.beaconInterference.researchLinkLabel)}
            </a>{" "}
            {t(($) => $.faq.items.beaconInterference.paragraph1After)}
            <br />
            <br />
            {t(($) => $.faq.items.beaconInterference.paragraph2)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="10">
          <AccordionTrigger>{t(($) => $.faq.items.whyPaid.question)}</AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.whyPaid.answer)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="11">
          <AccordionTrigger>
            {t(($) => $.faq.items.sourceCode.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.sourceCode.beforeLink)}
            <a
              href="https://github.com/dagstuan/skredvarselGarmin/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              {t(($) => $.faq.items.sourceCode.linkLabel)}
            </a>
            {t(($) => $.faq.items.sourceCode.afterLink)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="12" ref={vippsLoginRef}>
          <AccordionTrigger>
            {t(($) => $.faq.items.vippsLogin.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.vippsLogin.beforeLink)}
            <a
              href="https://vippsmobilepay.com/no/priser/logg-inn"
              className="hover:underline"
            >
              {t(($) => $.faq.items.vippsLogin.linkLabel)}
            </a>{" "}
            {t(($) => $.faq.items.vippsLogin.afterLink)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="13">
          <AccordionTrigger>{t(($) => $.faq.items.bugReport.question)}</AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.bugReport.answer)}
          </AccordionContent>
        </AccordionItem>

        <AccordionItem value="14">
          <AccordionTrigger>
            {t(($) => $.faq.items.contact.question)}
          </AccordionTrigger>
          <AccordionContent>
            {t(($) => $.faq.items.contact.beforeInstagram)}
            <a
              href="https://www.instagram.com/dagstuan/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              {t(($) => $.faq.items.contact.instagramLabel)}
            </a>{" "}
            {t(($) => $.faq.items.contact.betweenLinks)}
            <a
              href="mailto:d.stuan@gmail.com"
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 hover:underline"
            >
              {t(($) => $.faq.items.contact.emailLabel)}
            </a>{" "}
            {t(($) => $.faq.items.contact.afterEmail)}
          </AccordionContent>
        </AccordionItem>
      </Accordion>
    </div>
  );
};
