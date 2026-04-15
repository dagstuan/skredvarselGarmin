import { BuySubscriptionModal } from "../Components/BuySubscriptionModal";
import { useTranslation } from "react-i18next";

export const Component = () => {
  const { t } = useTranslation();

  return (
    <BuySubscriptionModal
      headerText={t(($) => $.buySubscription.title)}
      informationElement={
        <>
          {t(($) => $.buySubscription.addWatchLine1)}
          <br />
          <br />
          {t(($) => $.buySubscription.addWatchLine2)}
        </>
      }
      showLogin
    />
  );
};
