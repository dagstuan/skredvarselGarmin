import { Link as RouterLink } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { FacebookButton } from "../Buttons/FacebookButton";
import { GoogleButton } from "../Buttons/GoogleButton";
import { OrDivider } from "../OrDivider";
import { EmailLoginForm } from "../EmailLoginForm/EmailLoginForm";
import { usePathForCurrentLanguage } from "../../routes";

type LoginContentProps = {
  loginText?: string;
  email: string | undefined;
  handleEmailInputChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleSubmit: (e: React.FormEvent<HTMLFormElement>) => void;
  error: string | undefined;
  isPending: boolean;
};

export const LoginContent = (props: LoginContentProps) => {
  const { t } = useTranslation();
  const pathFor = usePathForCurrentLanguage();
  const {
    loginText,
    email,
    handleEmailInputChange,
    handleSubmit,
    error,
    isPending: isLoading,
  } = props;

  return (
    <div className="flex flex-col gap-7">
      {loginText && <p className="text-md text-center mb-2">{loginText}</p>}

      <div className="flex flex-col gap-2">
        <GoogleButton
          className="w-full"
          link={`/google-login?returnUrl=${pathFor("account")}`}
        />
        <FacebookButton
          className="w-full"
          link={`/facebook-login?returnUrl=${pathFor("account")}`}
        />
      </div>
      <OrDivider />
      <EmailLoginForm
        email={email}
        handleEmailInputChange={handleEmailInputChange}
        handleSubmit={handleSubmit}
        error={error}
        isLoading={isLoading}
      />
      <div className="flex justify-center">
        <RouterLink
          to={pathFor("faq", { hash: "vippslogin" })}
          className="hover:underline"
        >
          {t(($) => $.login.whyNoVippsLogin)}
        </RouterLink>
      </div>
    </div>
  );
};
