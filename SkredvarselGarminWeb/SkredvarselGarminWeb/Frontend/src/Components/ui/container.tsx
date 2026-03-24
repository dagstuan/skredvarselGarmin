import * as React from "react"
import { cn } from "../../lib/utils"

export interface ContainerProps extends React.HTMLAttributes<HTMLDivElement> {
  maxW?: "sm" | "md" | "lg" | "xl" | "2xl" | "3xl" | "4xl" | "5xl" | "6xl" | "7xl" | "full"
}

const Container = React.forwardRef<HTMLDivElement, ContainerProps>(
  ({ className, maxW = "7xl", ...props }, ref) => {
    const maxWidthClasses = {
      sm: "max-w-screen-sm",
      md: "max-w-screen-md",
      lg: "max-w-screen-lg",
      xl: "max-w-screen-xl",
      "2xl": "max-w-screen-2xl",
      "3xl": "max-w-[1920px]",
      "4xl": "max-w-[2560px]",
      "5xl": "max-w-[3200px]",
      "6xl": "max-w-[3840px]",
      "7xl": "max-w-[4096px]",
      full: "max-w-full",
    }

    return (
      <div
        ref={ref}
        className={cn(
          "mx-auto w-full px-4 sm:px-6 lg:px-8",
          maxWidthClasses[maxW],
          className
        )}
        {...props}
      />
    )
  }
)
Container.displayName = "Container"

export { Container }
