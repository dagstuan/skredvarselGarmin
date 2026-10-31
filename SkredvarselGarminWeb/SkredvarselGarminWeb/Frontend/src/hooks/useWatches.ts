import { useMutation, useQuery } from "@tanstack/react-query";
import { useTranslation } from "react-i18next";
import { api } from "../api";
import { queryClient } from "../main";
import { Watch } from "../types";
import { toast } from "../lib/toast";
import { AxiosError } from "axios";

const getWatches = async () =>
  api.get("/api/watches").then((res) => res.data as Watch[]);

const queryKey = ["watches"];

export const useWatches = () =>
  useQuery({ queryKey, queryFn: async () => getWatches() });

const addWatch = (key: string) => api.post(`/api/watches/${key}`);

// The backend answers 400 when no watch has the given code.
export const isWatchNotFoundError = (error: unknown) =>
  (error as AxiosError).response?.status === 400;

export const useAddWatch = (onSuccess?: () => void, onSettled?: () => void) => {
  const { t } = useTranslation();

  return useMutation({
    mutationFn: addWatch,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
      toast.success(t(($) => $.account.watches.added));
      onSuccess?.();
    },
    onError: (error) => {
      toast.error(
        isWatchNotFoundError(error)
          ? t(($) => $.account.watches.notFound)
          : t(($) => $.account.watches.addFailed),
      );
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
