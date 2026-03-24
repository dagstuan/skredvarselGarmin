import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "../../lib/utils"

const headingVariants = cva("font-bold tracking-tight", {
  variants: {
    size: {
      xs: "text-lg",
      sm: "text-xl",
      md: "text-xl",
      lg: "text-[30px]",
      xl: "text-4xl",
      "2xl": "text-5xl",
      "3xl": "text-6xl",
      "4xl": "text-7xl",
    },
    as: {
      h1: "",
      h2: "",
      h3: "",
      h4: "",
      h5: "",
      h6: "",
    },
  },
  defaultVariants: {
    size: "xl",
    as: "h2",
  },
})

export interface HeadingProps
  extends React.HTMLAttributes<HTMLHeadingElement>,
    VariantProps<typeof headingVariants> {
  as?: "h1" | "h2" | "h3" | "h4" | "h5" | "h6"
}

const Heading = React.forwardRef<HTMLHeadingElement, HeadingProps>(
  ({ className, size, as = "h2", ...props }, ref) => {
    const Component = as
    return (
      <Component
        ref={ref}
        className={cn(headingVariants({ size, as }), className)}
        {...props}
      />
    )
  }
)
Heading.displayName = "Heading"

export { Heading, headingVariants }
