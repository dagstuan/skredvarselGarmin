import { buttonVariants } from "../ui/button";
import { FaStripe, FaCreditCard, FaApplePay, FaGooglePay } from "react-icons/fa";
import { cn } from "../../lib/utils";
import { VariantProps } from "class-variance-authority";

type StripeButtonProps = {
  text?: string;
  link?: string;
  size?: VariantProps<typeof buttonVariants>["size"];
};

export const StripeButton = (props: StripeButtonProps) => {
  const { text = "Kjøp abonnement med", link = "/createStripeSubscription", size } = props;

  return (
    <div className="flex flex-col gap-0 items-start">
      <a
        href={link}
        className={cn(
          buttonVariants({ variant: "default", size }),
          "rounded bg-purple-600 hover:bg-purple-700"
        )}
      >
        {text}
        <FaStripe className="h-10 w-12 ml-2" />
      </a>
      <div className="flex items-center gap-1">
        <FaCreditCard title="Kort" className="w-6 h-auto" />
        <FaApplePay title="Apple pay" className="w-9 h-auto" />
        <FaGooglePay title="Google pay" className="w-9 h-auto" />
      </div>
    </div>
  );
};
