import { buttonVariants } from "../ui/button";
import { FcGoogle } from "react-icons/fc";
import { cn } from "../../lib/utils";
import { useTranslation } from "react-i18next";

type GoogleButtonProps = {
  link: string;
  className?: string;
};

export const GoogleButton = ({ link, className }: GoogleButtonProps) => {
  const { t } = useTranslation();

  return (
    <a
      href={link}
      className={cn(
        buttonVariants({ variant: "outline" }),
        "border-black rounded-md",
        className,
      )}
    >
      <FcGoogle className="h-6 w-6" />
      <span>{t(($) => $.buttons.google.login)}</span>
    </a>
  );
};
