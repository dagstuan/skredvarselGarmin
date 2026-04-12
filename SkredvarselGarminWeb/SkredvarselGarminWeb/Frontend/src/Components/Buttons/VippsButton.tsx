import { buttonVariants } from "../ui/button";
import { VippsIcon } from "../Icons/VippsIcon";
import { cn } from "../../lib/utils";
import { VariantProps } from "class-variance-authority";

type VippsButtonProps = {
  text?: string;
  link?: string;
  size?: VariantProps<typeof buttonVariants>["size"];
  className?: string;
};

export const VippsButton = (props: VippsButtonProps) => {
  const {
    text = "Fortsett med",
    link = "/createVippsAgreement",
    size = "lg",
    className,
  } = props;

  return (
    <a
      href={link}
      className={cn(
        buttonVariants({ size: size }),
        "bg-brand-vipps-500 text-white hover:bg-brand-vipps-600 flex items-center",
        className,
      )}
    >
      <span className="leading-none">{text}</span>
      <VippsIcon className="size-auto w-14 h-4 translate-y-0.5" />
    </a>
  );
};
