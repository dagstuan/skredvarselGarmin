import {
  Dialog,
  DialogPopup,
  DialogTitle,
  DialogClose,
  DialogHeader,
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
import { VippsButton } from "./Buttons/VippsButton";
import { EmailLoginForm } from "./EmailLoginForm/EmailLoginForm";
import { OrDivider } from "./OrDivider";

type BuySubscriptionModalProps = {
  headerText?: string;
  informationElement?: ReactElement;
};

export const BuySubscriptionModal = (props: BuySubscriptionModalProps) => {
  const {
    headerText = "Kjøp abonnement",
    informationElement = (
      <>
        Abonnement kan kjøpes direkte med Vipps,
        <br />
        eller logg inn for andre alternativer.
        <br />
        <br />
        Hvis du allerede har et abonnement kan du logge inn nedenfor for å endre
        det.
      </>
    ),
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
        <DialogHeader className="flex items-center justify-between w-full pb-4">
          <DialogTitle>{headerText}</DialogTitle>
          <DialogClose className="rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d="M18 6 6 18" />
              <path d="m6 6 12 12" />
            </svg>
            <span className="sr-only">Close</span>
          </DialogClose>
        </DialogHeader>
        <div className="w-full p-0">
          {!showSentEmail && (
            <div className="flex flex-col gap-8 w-full items-center">
              <div className="flex flex-col gap-5 w-[90%] md:w-[80%] items-center">
                <div className="w-full p-3 shadow-sm rounded-sm bg-gray-50">
                  <p className="text-md text-left">{informationElement}</p>
                </div>

                <div className="w-full flex flex-col">
                  <VippsButton
                    text="Kjøp abonnement med"
                    link={`/createVippsAgreement${watchKey ? `?watchKey=${watchKey}` : ""}`}
                  />
                </div>
              </div>

              <div className="w-full bg-gray-100 pt-4 pb-8 flex justify-center">
                <div className="w-[90%] md:w-[80%] max-w-sm flex flex-col gap-5">
                  <Heading as="h2" size="sm" className="text-center font-bold">
                    Logg inn / registrer deg
                  </Heading>
                  <div className="flex flex-col gap-5 w-full">
                    <div className="flex flex-col gap-2 w-full">
                      <GoogleButton
                        link={`/google-login?returnUrl=/account${watchKey ? `?watchKey=${watchKey}` : ""}`}
                      />
                      <FacebookButton
                        link={`/facebook-login?returnUrl=/account${watchKey ? `?watchKey=${watchKey}` : ""}`}
                      />
                    </div>

                    <OrDivider text="Eller" />
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
              </div>
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
