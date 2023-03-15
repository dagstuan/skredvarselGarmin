export type Subscription = {
  status: "ACTIVE" | "STOPPED" | "EXPIRED" | "PENDING" | "UNSUBSCRIBED";
  nextChargeDate: string | undefined;
  vippsConfirmationUrl: string | undefined;
};

export type User = {
  name: string;
  email: string;
  phoneNumber: string;
};
