import { buttonVariants } from "../ui/button";
import { FcGoogle } from "react-icons/fc";
import { cn } from "../../lib/utils";

type GoogleButtonProps = {
  link: string;
};

export const GoogleButton = ({ link }: GoogleButtonProps) => {
  return (
    <a
      href={link}
      className={cn(
        buttonVariants({ variant: "outline" }),
        "border-black rounded"
      )}
    >
      <FcGoogle className="h-6 w-6" />
      <span>Logg inn med Google</span>
    </a>
  );
};
