import { buttonVariants } from "../ui/button";
import { FcGoogle } from "react-icons/fc";
import { cn } from "../../lib/utils";

type GoogleButtonProps = {
  link: string;
  className?: string;
};

export const GoogleButton = ({ link, className }: GoogleButtonProps) => {
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
      <span>Logg inn med Google</span>
    </a>
  );
};
