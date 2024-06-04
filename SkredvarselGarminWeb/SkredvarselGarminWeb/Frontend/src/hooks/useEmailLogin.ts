import { api } from "../api";

export const sendLoginEmail = async (email: string) =>
  api.post(`/email-login-send?email=${email}&returnUrl=/account`);
