import { Navigate } from "react-router-dom";
import { useUser } from "../../hooks/useUser";
import { Spinner } from "@chakra-ui/react";
import { ReactElement } from "react";

type RequireAdminProps = {
  children: ReactElement;
};

export const RequireAdmin = ({ children }: RequireAdminProps) => {
  const { data: user, isLoading } = useUser();

  if (isLoading) {
    return <Spinner />;
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
