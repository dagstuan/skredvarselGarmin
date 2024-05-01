import {
  VStack,
  FormControl,
  Input,
  FormErrorMessage,
  Button,
  Text,
} from "@chakra-ui/react";
import { FacebookButton } from "../Buttons/FacebookButton";
import { GoogleButton } from "../Buttons/GoogleButton";
import { VippsButton } from "../Buttons/VippsButton";
import { OrDivider } from "../OrDivider";
import { useState } from "react";
import { useMutation } from "react-query";
import { sendLoginEmail } from "../../hooks/useEmailLogin";

type LoginContentProps = {
  loginText?: string;
  onSentEmail: () => void;
};

export const LoginContent = (props: LoginContentProps) => {
  const { loginText, onSentEmail } = props;

  const [email, setEmail] = useState<string | undefined>(undefined);
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    if (value !== undefined && value !== null) {
      setEmail(value);
    }
  };
  const [error, setError] = useState<string | undefined>();

  const { mutate, isLoading } = useMutation(sendLoginEmail, {
    onSuccess: () => {
      onSentEmail();
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (!email) {
      setError("Du må skrive en e-postadresse.");
    } else {
      mutate(email);
    }
  };

  return (
    <VStack gap={7} alignItems="stretch">
      {loginText && (
        <Text fontSize="md" align="center" mb={2}>
          {loginText}
        </Text>
      )}

      <VStack gap={5} alignItems="stretch">
        <VippsButton
          link="/vipps-login?returnUrl=/account"
          text="Fortsett med"
        />
        <GoogleButton link="/google-login?returnUrl=/account" />
        <FacebookButton link="/facebook-login?returnUrl=/account" />
      </VStack>
      <OrDivider text="Eller logg inn med e-post" />
      <form onSubmit={handleSubmit}>
        <FormControl isInvalid={!!error}>
          <Input
            type="email"
            bg="white"
            placeholder="E-post"
            value={email}
            onChange={handleInputChange}
          />
          <FormErrorMessage>{error}</FormErrorMessage>
        </FormControl>
        <Button
          mt={4}
          w="100%"
          colorScheme="green"
          isLoading={isLoading}
          type="submit"
        >
          Send innloggingslenke
        </Button>
      </form>
    </VStack>
  );
};
