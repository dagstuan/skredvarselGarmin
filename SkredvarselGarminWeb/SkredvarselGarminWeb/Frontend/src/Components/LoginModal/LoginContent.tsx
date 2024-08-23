import { VStack, Text, Center, Link } from "@chakra-ui/react";
import { FacebookButton } from "../Buttons/FacebookButton";
import { GoogleButton } from "../Buttons/GoogleButton";
import { OrDivider } from "../OrDivider";
import { Link as RouterLink } from "react-router-dom";
import { EmailLoginForm } from "../EmailLoginForm/EmailLoginForm";

type LoginContentProps = {
  loginText?: string;
  email: string | undefined;
  handleEmailInputChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleSubmit: (e: React.FormEvent<HTMLFormElement>) => void;
  error: string | undefined;
  isLoading: boolean;
};

export const LoginContent = (props: LoginContentProps) => {
  const {
    loginText,
    email,
    handleEmailInputChange,
    handleSubmit,
    error,
    isLoading,
  } = props;

  return (
    <VStack gap={7} alignItems="stretch">
      {loginText && (
        <Text fontSize="md" align="center" mb={2}>
          {loginText}
        </Text>
      )}

      <VStack gap={5} alignItems="stretch">
        <GoogleButton link="/google-login?returnUrl=/account" />
        <FacebookButton link="/facebook-login?returnUrl=/account" />
      </VStack>
      <OrDivider text="Eller logg inn med e-post" />
      <EmailLoginForm
        email={email}
        handleEmailInputChange={handleEmailInputChange}
        handleSubmit={handleSubmit}
        error={error}
        isLoading={isLoading}
      />
      <Center>
        <Link as={RouterLink} to="/faq#vippslogin">
          Hvorfor kan jeg ikke logge inn med Vipps?
        </Link>
      </Center>
    </VStack>
  );
};
