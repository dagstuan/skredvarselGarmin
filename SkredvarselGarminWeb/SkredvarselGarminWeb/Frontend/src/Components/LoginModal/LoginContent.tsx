import { Link as RouterLink } from "react-router-dom";
import { FacebookButton } from "../Buttons/FacebookButton";
import { GoogleButton } from "../Buttons/GoogleButton";
import { OrDivider } from "../OrDivider";
import { EmailLoginForm } from "../EmailLoginForm/EmailLoginForm";

type LoginContentProps = {
  loginText?: string;
  email: string | undefined;
  handleEmailInputChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleSubmit: (e: React.FormEvent<HTMLFormElement>) => void;
  error: string | undefined;
  isPending: boolean;
};

export const LoginContent = (props: LoginContentProps) => {
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
          link="/google-login?returnUrl=/account"
        />
        <FacebookButton
          className="w-full"
          link="/facebook-login?returnUrl=/account"
        />
      </div>
      <OrDivider text="Eller" />
      <EmailLoginForm
        email={email}
        handleEmailInputChange={handleEmailInputChange}
        handleSubmit={handleSubmit}
        error={error}
        isLoading={isLoading}
      />
      <div className="flex justify-center">
        <RouterLink to="/faq#vippslogin" className="hover:underline">
          Hvorfor kan jeg ikke logge inn med Vipps?
        </RouterLink>
      </div>
    </div>
  );
};
