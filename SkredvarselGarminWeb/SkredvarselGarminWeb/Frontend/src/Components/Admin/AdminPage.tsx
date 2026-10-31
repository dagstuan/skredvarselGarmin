import { Heading } from "../ui/heading";
import { Spinner } from "../ui/spinner";
import { useAdminData } from "../../hooks/useAdminData";
import { useTranslation } from "react-i18next";

export const AdminPage = () => {
  const { t } = useTranslation();
  const { data: adminData, isLoading } = useAdminData();

  if (isLoading || !adminData) {
    return (
      <div className="flex items-center justify-center p-8">
        <Spinner className="size-8" />
      </div>
    );
  }

  return (
    <div className="mx-auto w-full max-w-4xl px-4 py-6 sm:px-6 lg:px-8">
      <Heading as="h1" className="mb-10">
        {t(($) => $.admin.title)}
      </Heading>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-5">
        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">
            {t(($) => $.admin.numberOfUsers)}
          </dt>
          <dd className="text-3xl font-bold">{adminData.numUsers}</dd>
        </div>

        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">
            {t(($) => $.admin.watches)}
          </dt>
          <dd className="text-3xl font-bold">{adminData.watches}</dd>
        </div>

        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">
            {t(($) => $.admin.staleUsers)}
          </dt>
          <dd className="text-3xl font-bold">{adminData.staleUsers.length}</dd>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">
            {t(($) => $.admin.activeAgreements)}
          </dt>
          <dd className="text-3xl font-bold">{adminData.activeAgreements}</dd>
        </div>

        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">
            {t(($) => $.admin.unsubscribedAgreements)}
          </dt>
          <dd className="text-3xl font-bold">
            {adminData.unsubscribedAgreements}
          </dd>
        </div>

        <div className="flex flex-col">
          <dt className="text-sm font-medium text-gray-500">
            {t(($) => $.admin.activeOrUnsubscribedAgreements)}
          </dt>
          <dd className="text-3xl font-bold">
            {adminData.activeOrUnsubscribedAgreements}
          </dd>
        </div>
      </div>
    </div>
  );
};
