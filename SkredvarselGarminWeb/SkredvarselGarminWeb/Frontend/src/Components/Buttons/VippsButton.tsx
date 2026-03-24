import { buttonVariants } from "../ui/button";
import { VippsIcon } from "../Icons/VippsIcon";
import { cn } from "../../lib/utils";
import { VariantProps } from "class-variance-authority";

type VippsButtonProps = {
  text?: string;
  link?: string;
  size?: VariantProps<typeof buttonVariants>["size"];
};

export const VippsButton = (props: VippsButtonProps) => {
  const { text = "Fortsett med", link = "/createVippsAgreement", size } = props;

  return (
    <a
      href={link}
      className={cn(
        buttonVariants({ size }),
        "rounded bg-[#ff5b24] text-white hover:bg-[#ec6638]"
      )}
    >
      <span>{text}</span>
      <VippsIcon className="w-14 h-4 self-end" />
    </a>
  );
};
