import { useQuery } from "react-query";
import { api } from "../api";
import { User } from "../types";

const config = {
  headers: {
    "X-CSRF": "1",
  },
};

const fetchUser = async () =>
  api.get("/api/vipps-user", config).then((res) => res.data as User);

export const useUser = () =>
  useQuery(["user"], async () => fetchUser(), {
    staleTime: Infinity,
    cacheTime: Infinity,
    retry: false,
  });
