import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { User } from "../types";
import { usePathForCurrentLanguage } from "../routes";

export const useNavigateToAccountIfLoggedIn = (
  user: User | null | undefined,
  isLoadingUser: boolean,
  watchKey: string | null,
) => {
  const navigate = useNavigate();
  const pathFor = usePathForCurrentLanguage();

  useEffect(() => {
    if (user && !isLoadingUser) {
      navigate(
        pathFor("account", { search: watchKey ? `watchKey=${watchKey}` : undefined }),
      );
    }
  }, [isLoadingUser, navigate, pathFor, user, watchKey]);
};
