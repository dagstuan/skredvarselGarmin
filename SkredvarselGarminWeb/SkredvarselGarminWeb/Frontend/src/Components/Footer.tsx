import { ReactNode } from "react";
import { Link as RouterLink } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { usePathForCurrentLanguage } from "../routes";

const ListHeader = ({ children }: { children: ReactNode }) => {
  return <div className="font-medium text-lg mb-2">{children}</div>;
};

export const Footer = () => {
  const { t } = useTranslation();
  const pathFor = usePathForCurrentLanguage();

  return (
    <div className="bg-gray-50 text-gray-700">
      <div className="mx-auto w-full max-w-6xl px-4 pt-10 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-8">
          <div className="space-y-6 md:col-span-2">
            <div>{t(($) => $.footer.owner)}</div>
            <p className="text-sm">
              {t(($) => $.footer.sourcesPrefix)}
              <a
                href="https://www.varsom.no"
                className="underline hover:no-underline"
              >
                www.varsom.no
              </a>
              {t(($) => $.footer.sourcesMiddle)}
              <a
                href="https://www.lavinprognoser.se/"
                className="underline hover:no-underline"
              >
                www.lavinprognoser.se
              </a>
              {t(($) => $.footer.sourcesSuffix)}
            </p>
            <p className="text-sm">
              {t(($) => $.footer.iconsPrefix)}
              <a
                href="https://www.avalanches.org/"
                className="underline hover:no-underline"
              >
                {t(($) => $.footer.iconsLinkLabel)}
              </a>
            </p>
          </div>
          <div className="flex flex-col items-start space-y-2">
            <ListHeader>{t(($) => $.footer.aboutHeading)}</ListHeader>
            <RouterLink to={pathFor("faq")} className="hover:underline">
              {t(($) => $.footer.faq)}
            </RouterLink>
            <RouterLink to={pathFor("privacy")} className="hover:underline">
              {t(($) => $.footer.privacy)}
            </RouterLink>
            <RouterLink to={pathFor("salesConditions")} className="hover:underline">
              {t(($) => $.footer.salesConditions)}
            </RouterLink>
            <a
              href="https://github.com/dagstuan/skredvarselGarmin/"
              className="hover:underline"
            >
              {t(($) => $.footer.sourceCode)}
            </a>
          </div>
          <div className="flex flex-col items-start space-y-2">
            <ListHeader>{t(($) => $.footer.socialHeading)}</ListHeader>
            <a
              href="https://www.instagram.com/skredvarselgarmin/"
              className="hover:underline"
            >
              Instagram
            </a>
            <a href="https://github.com/dagstuan/" className="hover:underline">
              Github
            </a>
          </div>
        </div>
      </div>
      <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
        <p className="text-xs max-w-3xl">
          {t(($) => $.footer.disclaimer)}
        </p>
      </div>
    </div>
  );
};
