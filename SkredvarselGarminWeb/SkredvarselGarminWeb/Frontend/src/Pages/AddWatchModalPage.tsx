import { BuySubscriptionModal } from "../Components/BuySubscriptionModal";

export const Component = () => (
  <BuySubscriptionModal
    headerText="Kjøp abonnement"
    informationElement={
      <>
        Abonnement kan kjøpes direkte med Vipps, eller logg inn for andre
        alternativer. <br />
        <br />
        Hvis du allerede har kjøpt abonnement, kan du logge inn for å legge til
        klokken din.
      </>
    }
  />
);
