import { useMutation, useQuery } from "react-query";
import { api } from "../api";
import { queryClient } from "../main";
import { Subscription } from "../types";

const fetchSubscription = async () =>
  api
    .get("/api/subscription")
    .then((res) => (res.data ? (res.data as Subscription) : null));

export const useSubscription = () =>
  useQuery(["subscription"], async () => fetchSubscription());

const stopSubscription = async () => api.delete("/api/subscription");

export const useStopSubscription = () =>
  useMutation({
    mutationFn: stopSubscription,
    onSuccess: () => {
      queryClient.invalidateQueries("subscription");
    },
  });

const reactivateSubscription = async () =>
  api.put("/api/subscription/reactivate");

export const useReactivateSubscription = () =>
  useMutation({
    mutationFn: reactivateSubscription,
    onSuccess: () => {
      queryClient.invalidateQueries("subscription");
    },
  });
