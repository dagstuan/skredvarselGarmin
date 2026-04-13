import { buttonVariants } from "../ui/button";
import {
  FaStripe,
  FaCreditCard,
  FaApplePay,
  FaGooglePay,
} from "react-icons/fa";
import { cn } from "../../lib/utils";
import { VariantProps } from "class-variance-authority";

type StripeButtonProps = {
  className?: string;
  text?: string;
  link?: string;
  size?: VariantProps<typeof buttonVariants>["size"];
};

export const StripeButton = (props: StripeButtonProps) => {
  const {
    className,
    text = "Kjøp abonnement med",
    link = "/createStripeSubscription",
    size,
  } = props;

  return (
    <div className="flex flex-col gap-0 items-start">
      <a
        href={link}
        className={cn(
          buttonVariants({ variant: "default", size }),
          "rounded-md bg-purple-600 hover:bg-purple-700 flex items-center",
          className,
        )}
      >
        {text}
        <FaStripe className="size-auto w-16 h-8 -ml-2 mt-0.5" />
      </a>
      <div className="flex items-center gap-2">
        <FaCreditCard title="Kort" className="w-6 h-auto" />
        <FaApplePay title="Apple pay" className="w-9 h-auto" />
        <FaGooglePay title="Google pay" className="w-9 h-auto" />
      </div>
    </div>
  );
};
