import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { User } from "../types";

export const useNavigateToAccountIfLoggedIn = (
  user: User | null | undefined,
  isLoadingUser: boolean,
) => {
  const navigate = useNavigate();

  useEffect(() => {
    if (user && !isLoadingUser) {
      navigate("/account");
    }
  }, [user, isLoadingUser]);
};
