import { Flex, Icon, Text, HStack, IconButton } from "@chakra-ui/react";
import { BsWatch, BsTrash } from "react-icons/bs";
import { useRemoveWatch } from "../../hooks/useWatches";
import { Watch as WatchType } from "../../types";

export type WatchProps = {
  watch: WatchType;
};

export const Watch = ({ watch: { name, id } }: WatchProps) => {
  const removeWatch = useRemoveWatch();

  return (
    <HStack py={2} px={4} align={"center"}>
      <Flex w={8} h={8} align={"center"} justify={"center"} rounded={"full"}>
        <Icon as={BsWatch} w={5} h={5} />
      </Flex>
      <Text flex="1 1 100%" fontWeight={600}>
        {name}
      </Text>
      <IconButton
        aria-label={"delete"}
        icon={<BsTrash />}
        colorScheme="red"
        onClick={() => removeWatch.mutate(id)}
      >
        Remove watch
      </IconButton>
    </HStack>
  );
};
