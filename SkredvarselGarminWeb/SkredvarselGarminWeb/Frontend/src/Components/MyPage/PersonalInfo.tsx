import { UnorderedList, ListItem, Spinner } from "@chakra-ui/react";
import { useUser } from "../../hooks/useUser";

export const PersonalInfo = () => {
  const { data: user, isLoading } = useUser();

  if (isLoading) {
    return <Spinner />;
  }

  if (!user) {
    return null;
  }

  return (
    <UnorderedList listStyleType={"none"} marginInlineStart={0}>
      <ListItem>{user.name}</ListItem>
      <ListItem>{user.email}</ListItem>
    </UnorderedList>
  );
};
