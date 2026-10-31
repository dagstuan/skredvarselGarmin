import { buttonVariants } from "../ui/button";
import { SiFacebook } from "react-icons/si";
import { cn } from "../../lib/utils";
import { useTranslation } from "react-i18next";

type FacebookButtonProps = {
  link: string;
  className?: string;
};

export const FacebookButton = ({ link, className }: FacebookButtonProps) => {
  const { t } = useTranslation();

  return (
    <a
      href={link}
      className={cn(
        buttonVariants(),
        "rounded-md bg-brand-facebook-500 text-white hover:bg-brand-facebook-600 active:bg-brand-facebook-600",
        className,
      )}
    >
      <SiFacebook className="h-6 w-6" />
      <span>{t(($) => $.buttons.facebook.login)}</span>
    </a>
  );
};
