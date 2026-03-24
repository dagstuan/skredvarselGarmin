import { buttonVariants } from "../ui/button";
import { SiFacebook } from "react-icons/si";
import { cn } from "../../lib/utils";

type FacebookButtonProps = {
  link: string;
};

export const FacebookButton = ({ link }: FacebookButtonProps) => {
  return (
    <a
      href={link}
      className={cn(
        buttonVariants(),
        "rounded bg-[#385898] text-white hover:bg-[#314E89] active:bg-[#314E89]"
      )}
    >
      <SiFacebook className="h-6 w-6" />
      <span>Logg inn med Facebook</span>
    </a>
  );
};
