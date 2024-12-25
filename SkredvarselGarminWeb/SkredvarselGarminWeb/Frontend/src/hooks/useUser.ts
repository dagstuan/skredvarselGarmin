import { useQuery } from "@tanstack/react-query";
import { api } from "../api";
import { User } from "../types";

const config = {
  headers: {
    "X-CSRF": "1",
  },
};

const fetchUser = async () => {
  const res = await api.get("/api/user", config);
  return res.data ? (res.data as User) : null;
};

export const useUser = () =>
  useQuery({
    queryKey: ["user"],
    queryFn: fetchUser,
    staleTime: Infinity,
    gcTime: Infinity,
    retry: false,
  });
