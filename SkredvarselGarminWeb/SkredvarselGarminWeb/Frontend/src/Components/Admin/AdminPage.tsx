import {
  Container,
  Heading,
  Spinner,
  Stat,
  StatGroup,
  StatLabel,
  StatNumber,
} from "@chakra-ui/react";
import { useAdminData } from "../../hooks/useAdminData";

export const AdminPage = () => {
  const { data: adminData, isLoading } = useAdminData();

  if (isLoading || !adminData) {
    return <Spinner />;
  }

  return (
    <Container maxW="4xl" padding={25}>
      <Heading as="h1" mb={10}>
        Admin
      </Heading>

      <StatGroup mb={5}>
        <Stat>
          <StatLabel>Number of users</StatLabel>
          <StatNumber>{adminData.numUsers}</StatNumber>
        </Stat>

        <Stat>
          <StatLabel>Watches</StatLabel>
          <StatNumber>{adminData.watches}</StatNumber>
        </Stat>

        <Stat>
          <StatLabel>Stale users</StatLabel>
          <StatNumber>{adminData.staleUsers.length}</StatNumber>
        </Stat>
      </StatGroup>

      <StatGroup>
        <Stat>
          <StatLabel>Active agreements</StatLabel>
          <StatNumber>{adminData.activeAgreements}</StatNumber>
        </Stat>

        <Stat>
          <StatLabel>Unsubscribed agreements</StatLabel>
          <StatNumber>{adminData.unsubscribedAgreements}</StatNumber>
        </Stat>

        <Stat>
          <StatLabel>Active or unsubbed agreements</StatLabel>
          <StatNumber>{adminData.activeOrUnsubscribedAgreements}</StatNumber>
        </Stat>
      </StatGroup>
    </Container>
  );
};
