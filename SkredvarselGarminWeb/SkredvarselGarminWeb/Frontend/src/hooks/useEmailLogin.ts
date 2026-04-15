import { useMutation } from "@tanstack/react-query";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { api } from "../api";
import { usePathForCurrentLanguage } from "../routes";

export const useEmailLogin = (watchKey: string | null) => {
  const { t } = useTranslation();
  const pathFor = usePathForCurrentLanguage();
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
    mutationFn: (config: { email: string; watchKey: string | null }) =>
      api.post(
        `/email-login-send?email=${config.email}&returnUrl=${pathFor("account")}${config.watchKey ? `?watchKey=${config.watchKey}` : ""}`,
      ),
    onSuccess: () => {
      setShowSentEmail(true);
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (!email) {
      setError(t(($) => $.login.emailRequired));
    } else {
      mutate({ email, watchKey });
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
