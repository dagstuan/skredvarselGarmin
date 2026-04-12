import { Navigate } from "react-router-dom";
import { useUser } from "../../hooks/useUser";
import { ReactElement } from "react";
import { Spinner } from "../ui/spinner";

type RequireAdminProps = {
  children: ReactElement;
};

export const RequireAdmin = ({ children }: RequireAdminProps) => {
  const { data: user, isLoading } = useUser();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <Spinner className="size-8" />
      </div>
    );
  }

  if (!user) {
    setTimeout(() => {
      window.location.href = "/google-login?returnUrl=/admin";
    }, 0);
    return null;
  }

  if (!user.isAdmin) {
    return <Navigate to="/" replace />;
  }

  return children;
};
