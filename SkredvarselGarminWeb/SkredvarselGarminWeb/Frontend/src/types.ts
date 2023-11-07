export type Subscription = {
  status: "ACTIVE" | "STOPPED" | "EXPIRED" | "PENDING" | "UNSUBSCRIBED";
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
