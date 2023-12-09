type SubscriptionType = "Stripe" | "Vipps";

type StripeSubscriptionStatus =
  | "ACTIVE"
  | "UNSUBSCRIBED"
  | "CANCELED"
  | "INCOMPLETE"
  | "INCOMPLETE_EXPIRED"
  | "PAST_DUE"
  | "PAUSED"
  | "TRIALING"
  | "UNPAID";

type VippsAgreementStatus =
  | "ACTIVE"
  | "STOPPED"
  | "EXPIRED"
  | "PENDING"
  | "UNSUBSCRIBED";

export type Subscription<TType extends SubscriptionType> = {
  subscriptionType: TType;
  stripeSubscriptionStatus: TType extends "Stripe"
    ? StripeSubscriptionStatus
    : never;
  vippsAgreementStatus: TType extends "Vipps" ? VippsAgreementStatus : never;
  nextChargeDate: string | undefined;
  vippsConfirmationUrl: string | undefined;
};

export type User = {
  name: string;
  email: string;
  phoneNumber: string;
  isAdmin: boolean;
};

export type Watch = {
  id: string;
  name: string;
};

export type ProblemDetails = {
  type: string;
  title: string;
  status: number;
  detail: string;
};

type AdminDataUser = {
  id: string;
  name: string;
};

export type AdminData = {
  staleUsers: Array<AdminDataUser>;
  numUsers: number;
  activeAgreements: number;
  unsubscribedAgreements: number;
  activeOrUnsubscribedAgreements: number;
  watches: number;
};
