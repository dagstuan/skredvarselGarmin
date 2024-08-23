import { FormControl, Input, FormErrorMessage, Button } from "@chakra-ui/react";

type EmailLoginFormProps = {
  email: string | undefined;
  handleEmailInputChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleSubmit: (e: React.FormEvent<HTMLFormElement>) => void;
  error: string | undefined;
  isLoading: boolean;
};

export const EmailLoginForm = (props: EmailLoginFormProps) => {
  const { email, handleEmailInputChange, handleSubmit, error, isLoading } =
    props;

  return (
    <form onSubmit={handleSubmit}>
      <FormControl isInvalid={!!error}>
        <Input
          type="email"
          bg="white"
          placeholder="E-post"
          value={email}
          onChange={handleEmailInputChange}
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
  );
};
