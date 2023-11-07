import { useQuery } from "react-query";
import { api } from "../api";
import { AdminData } from "../types";

const fetchAdminData = () =>
  api.get("/api/admin").then((res) => res.data as AdminData);

export const useAdminData = () => useQuery(["adminData"], fetchAdminData);
