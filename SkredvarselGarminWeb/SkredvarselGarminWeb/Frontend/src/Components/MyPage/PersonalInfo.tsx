import { UnorderedList, ListItem, Spinner } from "@chakra-ui/react";
import { useUser } from "../../hooks/useUser";

const getFormattedPhoneNumber = (number: string) => `+${number}`;

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
      <ListItem>{getFormattedPhoneNumber(user.phoneNumber)}</ListItem>
      <ListItem>{user.email}</ListItem>
    </UnorderedList>
  );
};
