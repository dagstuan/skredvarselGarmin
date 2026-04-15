import { buttonVariants } from "../ui/button";
import {
  FaStripe,
  FaCreditCard,
  FaApplePay,
  FaGooglePay,
} from "react-icons/fa";
import { cn } from "../../lib/utils";
import { VariantProps } from "class-variance-authority";
import { useTranslation } from "react-i18next";

type StripeButtonProps = {
  className?: string;
  text?: string;
  link?: string;
  size?: VariantProps<typeof buttonVariants>["size"];
};

export const StripeButton = (props: StripeButtonProps) => {
  const { t } = useTranslation();
  const {
    className,
    text,
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
        {text ?? t(($) => $.buttons.stripe.buySubscriptionWith)}
        <FaStripe className="size-auto w-16 h-8 -ml-2 mt-0.5" />
      </a>
      <div className="flex items-center gap-2">
        <FaCreditCard
          title={t(($) => $.buttons.stripe.card)}
          className="w-6 h-auto"
        />
        <FaApplePay
          title={t(($) => $.buttons.stripe.applePay)}
          className="w-9 h-auto"
        />
        <FaGooglePay
          title={t(($) => $.buttons.stripe.googlePay)}
          className="w-9 h-auto"
        />
      </div>
    </div>
  );
};
