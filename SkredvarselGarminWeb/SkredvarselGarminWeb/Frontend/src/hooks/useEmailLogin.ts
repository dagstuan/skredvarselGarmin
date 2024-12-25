import { useState } from "react";
import { api } from "../api";
import { useMutation } from "@tanstack/react-query";

export const sendLoginEmail = async (email: string) =>
  api.post(`/email-login-send?email=${email}&returnUrl=/account`);

export const useEmailLogin = () => {
  const [showSentEmail, setShowSentEmail] = useState(false);

  const [email, setEmail] = useState<string | undefined>(undefined);
  const handleEmailInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    if (value !== undefined && value !== null) {
      setEmail(value);
    }
  };
  const [error, setError] = useState<string | undefined>();

  const { mutate, isPending } = useMutation({
    mutationFn: sendLoginEmail,
    onSuccess: () => {
      setShowSentEmail(true);
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

  return {
    email,
    handleEmailInputChange,
    error,
    isPending,
    handleSubmit,
    showSentEmail,
  };
};
