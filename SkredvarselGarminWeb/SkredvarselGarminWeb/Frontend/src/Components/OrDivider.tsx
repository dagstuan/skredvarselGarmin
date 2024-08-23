import { AbsoluteCenter, Box, Divider, Text } from "@chakra-ui/react";

type OrDividerProps = {
  text?: string;
};

export const OrDivider = ({ text = "Eller" }: OrDividerProps) => {
  return (
    <Box mb={2} mt={2} position="relative" whiteSpace="nowrap">
      <Divider />
      <AbsoluteCenter bg="transparent" px="4">
        {text}
      </AbsoluteCenter>
    </Box>
  );
};
