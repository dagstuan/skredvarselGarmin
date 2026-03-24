import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { Label } from "../ui/label";

type EmailLoginFormProps = {
  email: string | undefined;
  handleEmailInputChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleSubmit: (e: React.FormEvent<HTMLFormElement>) => void;
  error: string | undefined;
  isLoading: boolean;
};

export const EmailLoginForm = (props: EmailLoginFormProps) => {
  const { email, handleEmailInputChange, handleSubmit, error, isLoading } = props;

  return (
    <form onSubmit={handleSubmit}>
      <div className="space-y-2">
        <Input
          type="email"
          className="bg-white"
          placeholder="E-post"
          value={email}
          onChange={handleEmailInputChange}
          aria-invalid={!!error}
          aria-describedby={error ? "email-error" : undefined}
        />
        {error && (
          <p id="email-error" className="text-sm text-red-500">
            {error}
          </p>
        )}
      </div>
      <Button
        className="mt-4 w-full"
        variant="green"
        isLoading={isLoading}
        type="submit"
      >
        Logg inn med e-post
      </Button>
    </form>
  );
};
