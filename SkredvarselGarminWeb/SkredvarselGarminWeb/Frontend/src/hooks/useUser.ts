import { useQuery } from "react-query";
import { api } from "../api";

const config = {
  headers: {
    "X-CSRF": "1",
  },
};

const fetchUser = async () =>
  api.get("/vipps-user", config).then((res) => res.data);

export const useUser = () =>
  useQuery(["user"], async () => fetchUser(), {
    staleTime: Infinity,
    cacheTime: Infinity,
    retry: false,
  });
