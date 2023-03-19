import { useMutation, useQuery } from "react-query";
import { api } from "../api";
import { queryClient } from "../main";
import { Watch } from "../types";

const getWatches = async () =>
  api.get("/api/watches").then((res) => res.data as Watch[]);

export const useWatches = () => useQuery(["watches"], async () => getWatches());

const addWatch = (key: string) => api.post(`/api/watches/${key}`);

export const useAddWatch = () =>
  useMutation({
    mutationFn: addWatch,
    onSuccess: () => {
      queryClient.invalidateQueries("watches");
    },
  });

const removeWatch = (id: string) => api.delete(`/api/watches/${id}`);

export const useRemoveWatch = () =>
  useMutation({
    mutationFn: removeWatch,
    onSuccess: () => {
      queryClient.invalidateQueries("watches");
    },
  });
