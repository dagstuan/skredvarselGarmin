import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { User } from "../types";

export const useNavigateToAccountIfLoggedIn = (
  user: User | null | undefined,
  isLoadingUser: boolean,
  watchKey: string | null,
) => {
  const navigate = useNavigate();

  useEffect(() => {
    if (user && !isLoadingUser) {
      navigate(`/account${watchKey ? `?watchKey=${watchKey}` : ""}`);
    }
  }, [user, isLoadingUser]);
};
