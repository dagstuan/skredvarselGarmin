import { useQuery } from "react-query";
import { api } from "../api";
import { User } from "../types";

const config = {
  headers: {
    "X-CSRF": "1",
  },
};

const fetchUser = async () => {
  const res = await api.get("/api/user", config);
  return res.data as User;
};

export const useUser = () =>
  useQuery(["user"], fetchUser, {
    staleTime: Infinity,
    cacheTime: Infinity,
    retry: false,
  });
