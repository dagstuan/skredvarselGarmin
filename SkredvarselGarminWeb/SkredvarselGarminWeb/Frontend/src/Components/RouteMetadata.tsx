import { useTranslation } from "react-i18next";
import {
  buildLocalizedPath,
  defaultLanguage,
  useCurrentLanguage,
  useCurrentRouteKey,
} from "../routes";
import { supportedLanguages, type AppLanguage } from "../i18n/resources";

const ogLocales: Record<AppLanguage, string> = {
  no: "nb_NO",
  en: "en_GB",
  sv: "sv_SE",
};

const hreflangCodes: Record<AppLanguage, string> = {
  no: "nb",
  en: "en",
  sv: "sv",
};

const ogImageUrl = "https://skredvarsel.app/og-image.jpg";

// Title, meta tags, canonical and hreflang links for the current route. React
// hoists these into <head>, so they must not also be in index.html.
export const RouteMetadata = () => {
  const { t } = useTranslation();
  const routeKey = useCurrentRouteKey();
  const language = useCurrentLanguage();

  const title = t(($) => $.seo[routeKey].title);
  const description = t(($) => $.seo[routeKey].description);

  const urlFor = (lang: AppLanguage) =>
    `${window.location.origin}${buildLocalizedPath(lang, routeKey)}`;
  const canonicalUrl = urlFor(language);

  return (
    <>
      <title>{title}</title>
      <meta name="description" content={description} />
      <meta property="og:type" content="website" />
      <meta property="og:image" content={ogImageUrl} />
      <meta property="og:title" content={title} />
      <meta property="og:description" content={description} />
      <meta property="og:image:alt" content={description} />
      <meta property="og:url" content={canonicalUrl} />
      <meta property="og:locale" content={ogLocales[language]} />
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:image" content={ogImageUrl} />
      <meta name="twitter:title" content={title} />
      <meta name="twitter:description" content={description} />
      <link rel="canonical" href={canonicalUrl} />
      {supportedLanguages.map((lang) => (
        <link
          key={lang}
          rel="alternate"
          hrefLang={hreflangCodes[lang]}
          href={urlFor(lang)}
        />
      ))}
      <link
        rel="alternate"
        hrefLang="x-default"
        href={urlFor(defaultLanguage)}
      />
    </>
  );
};
