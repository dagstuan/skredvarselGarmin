import { buttonVariants } from "./ui/button";
import { cn } from "../lib/utils";
import { VariantProps } from "class-variance-authority";

import ciqLogo from "../assets/ciq_logo.png?format=webp&as=meta:width;height;src&imagetools";

type CiqStoreButtonProps = {
  size?: VariantProps<typeof buttonVariants>["size"];
  className?: string;
};

export const CiqStoreButton = (props: CiqStoreButtonProps) => {
  const { size, className } = props;
  const isLarge = size === "lg";

  return (
    <a
      target="_blank"
      rel="noopener noreferrer"
      href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
      className={cn(
        "inline-flex items-center rounded bg-ciq-button text-white hover:bg-ciq-button-hover transition-colors w-max",
        isLarge ? "h-12 gap-3 rounded-md px-3" : "gap-3 h-9 px-3",
        className,
      )}
    >
      <img
        className={isLarge ? "h-10 w-auto shrink-0" : "h-6 w-auto"}
        src={ciqLogo.src}
        width={ciqLogo.width}
        height={ciqLogo.height}
        alt=""
      />
      <div className="flex flex-col gap-0.5">
        <span className="text-xs leading-none">Last ned på</span>
        <span
          className={cn(
            "font-semibold",
            isLarge ? "text-lg" : "text-sm",
            "leading-none",
          )}
        >
          Connect IQ Store
        </span>
      </div>
    </a>
  );
};
