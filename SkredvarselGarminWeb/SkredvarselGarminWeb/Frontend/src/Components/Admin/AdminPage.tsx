import { Container } from "../ui/container";
import { Heading } from "../ui/heading";
import { useAdminData } from "../../hooks/useAdminData";

export const AdminPage = () => {
  const { data: adminData, isLoading } = useAdminData();

  if (isLoading || !adminData) {
    return (
      <div className="flex items-center justify-center p-8">
        <svg
          className="animate-spin h-8 w-8"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          ></circle>
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          ></path>
        </svg>
      </div>
    );
  }

  return (
    <Container maxW="4xl" className="py-6">
      <Heading as="h1" className="mb-10">
        Admin
      </Heading>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-5">
        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">Number of users</dt>
          <dd className="text-3xl font-bold">{adminData.numUsers}</dd>
        </div>

        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">Watches</dt>
          <dd className="text-3xl font-bold">{adminData.watches}</dd>
        </div>

        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">Stale users</dt>
          <dd className="text-3xl font-bold">{adminData.staleUsers.length}</dd>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">Active agreements</dt>
          <dd className="text-3xl font-bold">{adminData.activeAgreements}</dd>
        </div>

        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">Unsubscribed agreements</dt>
          <dd className="text-3xl font-bold">{adminData.unsubscribedAgreements}</dd>
        </div>

        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">Active or unsubbed agreements</dt>
          <dd className="text-3xl font-bold">{adminData.activeOrUnsubscribedAgreements}</dd>
        </div>
      </div>
    </Container>
  );
};
