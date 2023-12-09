import { useMutation, useQuery } from "react-query";
import { api } from "../api";
import { queryClient } from "../main";
import { Subscription } from "../types";

const fetchSubscription = async () =>
  api
    .get("/api/subscription")
    .then((res) =>
      res.data ? (res.data as Subscription<"Vipps" | "Stripe">) : null,
    );

export const useSubscription = () =>
  useQuery(["subscription"], async () => fetchSubscription());

const stopVippsAgreement = async () => api.delete("/api/vippsAgreement");

export const useStopVippsAgreement = () =>
  useMutation({
    mutationFn: stopVippsAgreement,
    onSuccess: () => {
      queryClient.invalidateQueries("subscription");
    },
  });

const reactivateVippsAgreement = async () =>
  api.put("/api/vippsAgreement/reactivate");

export const useReactivateVippsAgreement = () =>
  useMutation({
    mutationFn: reactivateVippsAgreement,
    onSuccess: () => {
      queryClient.invalidateQueries("subscription");
    },
  });
