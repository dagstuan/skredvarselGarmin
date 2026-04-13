import {
  Dialog,
  DialogPopup,
  DialogTitle,
  DialogHeader,
  DialogDescription,
} from "./ui/dialog";
import { Heading } from "./ui/heading";
import { ReactElement, useState, useEffect } from "react";
import { FaPaperPlane } from "react-icons/fa";
import { Link as RouterLink, useSearchParams } from "react-router-dom";
import { useEmailLogin } from "../hooks/useEmailLogin";
import { useNavigateOnClose } from "../hooks/useNavigateOnClose";
import { useNavigateToAccountIfLoggedIn } from "../hooks/useNavigateToAccountIfLoggedIn";
import { useUser } from "../hooks/useUser";
import { FacebookButton } from "./Buttons/FacebookButton";
import { GoogleButton } from "./Buttons/GoogleButton";
import { StripeButton } from "./Buttons/StripeButton";
import { VippsButton } from "./Buttons/VippsButton";
import { EmailLoginForm } from "./EmailLoginForm/EmailLoginForm";
import { OrDivider } from "./OrDivider";

type BuySubscriptionModalProps = {
  headerText?: string;
  informationElement?: ReactElement;
  showLogin?: boolean;
};

export const BuySubscriptionModal = (props: BuySubscriptionModalProps) => {
  const {
    headerText = "Kjøp abonnement",
    informationElement = (
      <>
        Abonnement kjøpes med Vipps eller Stripe. Velg hvordan du vil kjøpe
        abonnement.
      </>
    ),
    showLogin = false,
  } = props;

  const [searchParams] = useSearchParams();
  const watchKey = searchParams.get("watchKey");

  const { data: user, isLoading: isLoadingUser } = useUser();

  useNavigateToAccountIfLoggedIn(user, isLoadingUser, watchKey);

  const { isClosing, onClose } = useNavigateOnClose("/");

  // Delay opening to allow mount animation
  const [shouldOpen, setShouldOpen] = useState(false);
  useEffect(() => {
    if (!isLoadingUser) {
      const timer = setTimeout(() => setShouldOpen(true), 10);
      return () => clearTimeout(timer);
    }
  }, [isLoadingUser]);

  const {
    email,
    showSentEmail,
    error,
    handleEmailInputChange,
    handleSubmit,
    isPending,
  } = useEmailLogin(watchKey);

  return (
    <Dialog
      open={shouldOpen && !isClosing}
      onOpenChange={(open) => !open && onClose()}
    >
      <DialogPopup className="flex flex-col items-center overflow-hidden">
        <DialogHeader className="w-full pb-4">
          <DialogTitle>{headerText}</DialogTitle>
          <DialogDescription className="sr-only">
            Velg hvordan du vil kjope abonnement eller logge inn for a endre
            det.
          </DialogDescription>
        </DialogHeader>
        <div className="w-full">
          {!showSentEmail && (
            <div className="flex flex-col gap-8 w-full items-center">
              <div className="flex flex-col gap-5 items-center w-full">
                {informationElement && (
                  <div className="w-full p-3 shadow-sm rounded-sm bg-gray-50">
                    <p className="text-md text-left">{informationElement}</p>
                  </div>
                )}

                <div className="w-full flex flex-col">
                  <VippsButton
                    className="w-full"
                    text="Kjøp abonnement med"
                    link={`/createVippsAgreement${watchKey ? `?watchKey=${watchKey}` : ""}`}
                  />
                </div>

                <div className="relative w-full">
                  <OrDivider text="Eller" bgClassName="bg-white" />
                </div>

                <div className="w-full flex flex-col">
                  <StripeButton
                    className="w-full"
                    link={`/createStripeSubscription${watchKey ? `?watchKey=${watchKey}` : ""}`}
                  />
                </div>
              </div>

              {showLogin && (
                <div className="w-full bg-gray-100 px-4 pt-4 pb-8 rounded-md">
                  <div className="w-full flex flex-col gap-5">
                    <Heading as="h2" className="text-center font-bold text-xl">
                      Logg inn for å administrere abonnement
                    </Heading>
                    <div className="w-full flex flex-col gap-2">
                      <GoogleButton
                        className="w-full"
                        link={`/google-login?returnUrl=/account${watchKey ? `?watchKey=${watchKey}` : ""}`}
                      />
                      <FacebookButton
                        className="w-full"
                        link={`/facebook-login?returnUrl=/account${watchKey ? `?watchKey=${watchKey}` : ""}`}
                      />
                    </div>

                    <OrDivider text="Eller" bgClassName="bg-gray-100" />
                    <div className="w-full flex flex-col">
                      <EmailLoginForm
                        email={email}
                        handleEmailInputChange={handleEmailInputChange}
                        handleSubmit={handleSubmit}
                        error={error}
                        isLoading={isPending}
                      />
                    </div>
                    <div className="flex justify-center">
                      <RouterLink
                        to="/faq#vippslogin"
                        className="hover:underline"
                      >
                        Hvorfor kan jeg ikke logge inn med Vipps?
                      </RouterLink>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
          {showSentEmail && (
            <div className="flex flex-col gap-6 pb-6 items-center">
              <div className="flex items-center justify-center bg-green-500 text-white rounded-full w-28 h-28">
                <FaPaperPlane className="w-16 h-16" />
              </div>
              <p>Sjekk innboksen din for en innloggingslenke.</p>
            </div>
          )}
        </div>
      </DialogPopup>
    </Dialog>
  );
};
