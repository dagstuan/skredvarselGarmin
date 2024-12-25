import { useMutation, useQuery } from "@tanstack/react-query";
import { api } from "../api";
import { queryClient } from "../main";
import { Subscription } from "../types";

const fetchSubscription = async () =>
  api
    .get("/api/subscription")
    .then((res) =>
      res.data ? (res.data as Subscription<"Vipps" | "Stripe">) : null,
    );

const queryKey = ["subscription"];

export const useSubscription = () =>
  useQuery({
    queryKey,
    queryFn: async () => fetchSubscription(),
  });

const stopVippsAgreement = async () => api.delete("/api/vippsAgreement");

export const useStopVippsAgreement = () =>
  useMutation({
    mutationFn: stopVippsAgreement,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
    },
  });

const reactivateVippsAgreement = async () =>
  api.put("/api/vippsAgreement/reactivate");

export const useReactivateVippsAgreement = () =>
  useMutation({
    mutationFn: reactivateVippsAgreement,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey });
    },
  });
