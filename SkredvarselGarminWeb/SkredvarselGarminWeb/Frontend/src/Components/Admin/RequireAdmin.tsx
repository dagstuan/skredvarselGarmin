import { Navigate } from "react-router-dom";
import { useUser } from "../../hooks/useUser";
import { Spinner } from "@chakra-ui/react";

type RequireAdminProps = {
  children: JSX.Element;
};

export const RequireAdmin = ({ children }: RequireAdminProps) => {
  const { data: user, isLoading } = useUser();

  if (isLoading) {
    return <Spinner />;
  }

  if (!user) {
    setTimeout(() => {
      window.location.href = "/vipps-login?returnUrl=/admin";
    }, 0);
    return null;
  }

  if (!user.isAdmin) {
    return <Navigate to="/" replace />;
  }

  return children;
};
