import {
  Dialog,
  DialogPopup,
  DialogTitle,
  DialogClose,
} from "../ui/dialog";
import { useNavigateOnClose } from "../../hooks/useNavigateOnClose";
import { LoginContent } from "./LoginContent";

import { FaPaperPlane } from "react-icons/fa";
import { useEmailLogin } from "../../hooks/useEmailLogin";

type LoginModalProps = {
  loginText?: string;
};

export const LoginModal = (props: LoginModalProps) => {
  const { loginText } = props;

  const { isClosing, onClose } = useNavigateOnClose("/");

  const {
    email,
    showSentEmail,
    error,
    handleEmailInputChange,
    handleSubmit,
    isPending,
  } = useEmailLogin(null);

  return (
    <Dialog open={!isClosing} onOpenChange={(open) => !open && onClose()}>
      <DialogPopup className="flex flex-col items-center">
        <div className="flex items-center justify-between w-full pb-4">
          <DialogTitle>
            {!showSentEmail ? "Logg inn" : "E-post sendt"}
          </DialogTitle>
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
        </div>
        <div className="w-full pb-9 max-w-sm">
          {!showSentEmail && (
            <LoginContent
              loginText={loginText}
              email={email}
              handleEmailInputChange={handleEmailInputChange}
              handleSubmit={handleSubmit}
              error={error}
              isPending={isPending}
            />
          )}
          {showSentEmail && (
            <div className="flex flex-col gap-6 items-center">
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
