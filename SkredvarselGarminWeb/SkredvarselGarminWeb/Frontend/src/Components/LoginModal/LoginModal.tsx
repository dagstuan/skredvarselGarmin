import {
  Dialog,
  DialogPopup,
  DialogTitle,
  DialogHeader,
  DialogDescription,
} from "../ui/dialog";
import { useNavigateOnClose } from "../../hooks/useNavigateOnClose";
import { LoginContent } from "./LoginContent";

import { FaPaperPlane } from "react-icons/fa";
import { useEmailLogin } from "../../hooks/useEmailLogin";
import { useTranslation } from "react-i18next";

type LoginModalProps = {
  loginText?: string;
};

export const LoginModal = (props: LoginModalProps) => {
  const { t } = useTranslation();
  const { loginText } = props;

  const { isClosing, onClose } = useNavigateOnClose("home");

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
        <DialogHeader className="w-full pb-4">
          <DialogTitle>
            {!showSentEmail
              ? t(($) => $.login.title)
              : t(($) => $.login.emailSentTitle)}
          </DialogTitle>
          <DialogDescription className="sr-only">
            {!showSentEmail
              ? t(($) => $.login.loginDescription)
              : t(($) => $.login.emailSentDescription)}
          </DialogDescription>
        </DialogHeader>
        <div className="w-full pb-4 max-w-sm">
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
              <p>{t(($) => $.common.checkInbox)}</p>
            </div>
          )}
        </div>
      </DialogPopup>
    </Dialog>
  );
};
