import { buttonVariants } from "./ui/button";
import { cn } from "../lib/utils";
import { VariantProps } from "class-variance-authority";

import ciqLogo from "../assets/ciq_logo.png?format=webp&as=meta:width;height;src&imagetools";

type CiqStoreButtonProps = {
  size?: VariantProps<typeof buttonVariants>["size"];
};

export const CiqStoreButton = (props: CiqStoreButtonProps) => {
  const isLarge = props.size === "lg";

  return (
    <a
      target="_blank"
      rel="noopener noreferrer"
      href="https://apps.garmin.com/en-US/apps/35174bf3-b1da-4391-9426-70bcb210c292"
      className={cn(
        "inline-flex items-center gap-3 rounded bg-ciq-button text-white hover:bg-ciq-button-hover transition-colors",
        isLarge ? "h-12 px-4" : "h-9 px-3"
      )}
    >
      <img
        className={isLarge ? "h-8 w-auto" : "h-6 w-auto"}
        src={ciqLogo.src}
        width={ciqLogo.width}
        height={ciqLogo.height}
        alt=""
      />
      <div className="flex flex-col">
        <span className="text-xs">Last ned på</span>
        <span className={isLarge ? "text-base font-semibold" : "text-sm font-semibold"}>Connect IQ Store</span>
      </div>
    </a>
  );
};
