import { BuySubscriptionModal } from "../Components/BuySubscriptionModal";

export const Component = () => (
  <BuySubscriptionModal
    headerText="Kjøp abonnement"
    informationElement={
      <>
        Abonnement kan kjøpes med Vipps eller Stripe.
        <br />
        <br />
        Hvis du allerede har et abonnement, kan du logge inn for å legge til
        klokken din.
      </>
    }
    showLogin
  />
);
