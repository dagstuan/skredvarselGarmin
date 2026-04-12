import * as React from "react";
import { cn } from "../../lib/utils";

export interface HeadingProps extends React.HTMLAttributes<HTMLHeadingElement> {
  as: "h1" | "h2" | "h3" | "h4" | "h5" | "h6";
}

const Heading = React.forwardRef<HTMLHeadingElement, HeadingProps>(
  ({ className, as, ...props }, ref) => {
    const Component = as;
    return (
      <Component
        ref={ref}
        className={cn("font-bold tracking-tight", className)}
        {...props}
      />
    );
  },
);
Heading.displayName = "Heading";

export { Heading };
