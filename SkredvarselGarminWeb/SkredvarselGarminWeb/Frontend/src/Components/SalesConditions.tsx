import { Heading } from "./ui/heading";
import { useTranslation } from "react-i18next";

export const SalesConditions = () => {
  const { t } = useTranslation();

  return (
    <div className="m-auto flex flex-col gap-10 max-w-4xl p-10">
      <div>
        <Heading as="h2" className="pb-4 text-4xl">
          {t(($) => $.salesConditions.title)}
        </Heading>

        <p className="text-xl">{t(($) => $.salesConditions.intro)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.seller.title)}
        </Heading>

        <p className="whitespace-pre-line">{t(($) => $.salesConditions.seller.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.buyer.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.buyer.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.payment.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.payment.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.fees.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.fees.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.renewal.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.renewal.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.delivery.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.delivery.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.cancellation.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.cancellation.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.withdrawal.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.withdrawal.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.disputeResolution.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.disputeResolution.paragraph)}</p>
      </div>

      <div>
        <Heading as="h3" className="pb-4 text-2xl">
          {t(($) => $.salesConditions.defects.title)}
        </Heading>

        <p>{t(($) => $.salesConditions.defects.paragraph)}</p>
      </div>
    </div>
  );
};
