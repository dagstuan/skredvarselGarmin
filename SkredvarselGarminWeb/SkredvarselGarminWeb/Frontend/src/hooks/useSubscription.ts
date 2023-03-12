import { useMutation, useQuery } from "react-query";
import { api } from "../api";
import { queryClient } from "../main";
import { Subscription } from "../types";

const fetchSubscription = async () =>
  api
    .get("/api/subscription")
    .then((res) => (res.data ? (res.data as Subscription) : null));

const stopSubscription = async () => api.delete("/api/subscription");

export const useSubscription = () =>
  useQuery(["subscription"], async () => fetchSubscription());

export const useStopSubscription = () =>
  useMutation({
    mutationFn: stopSubscription,
    onSuccess: () => {
      queryClient.invalidateQueries("subscription");
    },
  });
