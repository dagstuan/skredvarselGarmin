"use client";

import * as React from "react";
import { Menu as MenuPrimitive } from "@base-ui/react/menu";
import { cn } from "@/lib/utils";

function Menu({ modal = false, ...props }: MenuPrimitive.Root.Props) {
  return <MenuPrimitive.Root data-slot="menu" modal={modal} {...props} />;
}

function MenuTrigger({ ...props }: MenuPrimitive.Trigger.Props) {
  return <MenuPrimitive.Trigger data-slot="menu-trigger" {...props} />;
}

function MenuPortal({ ...props }: MenuPrimitive.Portal.Props) {
  return <MenuPrimitive.Portal data-slot="menu-portal" {...props} />;
}

function MenuContent({
  className,
  sideOffset = 8,
  alignOffset = 0,
  ...props
}: MenuPrimitive.Popup.Props &
  Pick<MenuPrimitive.Positioner.Props, "sideOffset" | "alignOffset" | "side" | "align">) {
  return (
    <MenuPortal>
      <MenuPrimitive.Positioner
        data-slot="menu-positioner"
        sideOffset={sideOffset}
        alignOffset={alignOffset}
      >
        <MenuPrimitive.Popup
          data-slot="menu-content"
          className={cn(
            "bg-background text-foreground data-open:animate-in data-closed:animate-out data-closed:fade-out-0 data-open:fade-in-0 data-closed:zoom-out-95 data-open:zoom-in-95 z-50 min-w-48 rounded-xl border border-border p-1 shadow-lg outline-none",
            className,
          )}
          {...props}
        />
      </MenuPrimitive.Positioner>
    </MenuPortal>
  );
}

function MenuItem({ className, ...props }: MenuPrimitive.Item.Props) {
  return (
    <MenuPrimitive.Item
      data-slot="menu-item"
      className={cn(
        "data-highlighted:bg-muted data-highlighted:text-foreground flex cursor-pointer items-center gap-3 rounded-lg px-3 py-2 text-sm outline-none",
        className,
      )}
      {...props}
    />
  );
}

export { Menu, MenuContent, MenuItem, MenuPortal, MenuTrigger };