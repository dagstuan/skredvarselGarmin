import { Icon } from "@chakra-ui/react";
import { ComponentProps } from "react";

export const ChevronIcon = (props: ComponentProps<typeof Icon>) => (
  <Icon viewBox="0 0 332 144" {...props}>
    <path
      fill="currentColor"
      d="M 324.001 27.75 L 173.997 140.25 c -5.334 4 -12.667 4 -18 0 L 6.001 27.75 c -6.627 -4.971 -7.971 -14.373 -3 -21 c 2.947 -3.93 7.451 -6.001 12.012 -6.001 c 3.131 0 6.29 0.978 8.988 3.001 L 164.998 109.5 l 141.003 -105.75 c 6.629 -4.972 16.03 -3.627 21 3 C 331.972 13.377 330.628 22.779 324.001 27.75 z"
    ></path>
  </Icon>
);
