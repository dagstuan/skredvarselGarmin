import { Heading } from "./ui/heading";
import { useTranslation } from "react-i18next";

export const PrivacyPolicy = () => {
  const { t } = useTranslation();

  return (
    <div className="m-auto flex flex-col max-w-4xl gap-10 p-10">
      <div>
        <Heading as="h2" className="mb-6 text-4xl">
          {t(($) => $.privacy.title)}
        </Heading>

        <p className="text-xl">{t(($) => $.privacy.intro)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.privacy.about.title)}
        </Heading>

        <p>{t(($) => $.privacy.about.paragraph1)}</p>
        <p className="mt-4">{t(($) => $.privacy.about.contactIntro)}</p>
        <ul className="list-disc list-inside mt-4">
          <li>
            {t(($) => $.privacy.about.addressLabel)}: {t(($) => $.privacy.about.addressValue)}
          </li>
          <li>
            {t(($) => $.privacy.about.orgNumberLabel)}: {t(($) => $.privacy.about.orgNumberValue)}
          </li>
        </ul>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.privacy.personalData.title)}
        </Heading>

        <p>{t(($) => $.privacy.personalData.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.privacy.collectedInfo.title)}
        </Heading>

        <p>{t(($) => $.privacy.collectedInfo.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.privacy.cookies.title)}
        </Heading>

        <p>{t(($) => $.privacy.cookies.paragraph1)}</p>
        <br />

        <p>{t(($) => $.privacy.cookies.paragraph2)}</p>
        <br />
        <p>{t(($) => $.privacy.cookies.paragraph3)}</p>
      </div>
      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.privacy.cookieTypes.title)}
        </Heading>

        <p>{t(($) => $.privacy.cookieTypes.intro)}</p>
        <br />
        <Heading as="h4" className="pb-2 text-xl">
          {t(($) => $.privacy.cookieTypes.paymentTitle)}
        </Heading>
        <ul className="list-disc list-inside">
          <li>{t(($) => $.privacy.cookieTypes.paymentProvider)}</li>
          <li>
            {t(($) => $.privacy.cookieTypes.vippsPolicyPrefix)}
            <a
              className="text-blue-600 hover:underline"
              href="https://www.vipps.no/vilkar/cookie-og-personvern/"
            >
              {t(($) => $.privacy.cookieTypes.vippsPolicyLabel)}
            </a>
          </li>
        </ul>
      </div>
      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.privacy.deletionRequest.title)}
        </Heading>

        <p>
          {t(($) => $.privacy.deletionRequest.paragraphBefore)}
          <a href="mailto:d.stuan@gmail.com" className="hover:underline">
            d.stuan@gmail.com
          </a>
          {t(($) => $.privacy.deletionRequest.paragraphAfter)}
        </p>
      </div>
    </div>
  );
};
