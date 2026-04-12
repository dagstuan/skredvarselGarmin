import { useMutation, useQuery } from "@tanstack/react-query";
import { api } from "../api";
import { queryClient } from "../main";
import { Watch } from "../types";
import { toast } from "../lib/toast";

const getWatches = async () =>
  api.get("/api/watches").then((res) => res.data as Watch[]);

const queryKey = ["watches"];

export const useWatches = () =>
  useQuery({ queryKey, queryFn: async () => getWatches() });

const addWatch = (key: string) => api.post(`/api/watches/${key}`);

export const useAddWatch = (onSuccess?: () => void, onSettled?: () => void) => {
  return useMutation({
    mutationFn: addWatch,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
      toast.success("Klokke lagt til");
      onSuccess?.();
    },
    onSettled,
  });
};

const removeWatch = (id: string) => api.delete(`/api/watches/${id}`);

export const useRemoveWatch = () =>
  useMutation({
    mutationFn: removeWatch,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
    },
  });
