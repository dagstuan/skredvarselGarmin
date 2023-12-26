import axios, { AxiosError } from "axios";

export const api = axios.create({
  baseURL: "/",
  timeout: 30000,
});

api.interceptors.response.use(
  (r) => r,
  async (err: AxiosError) => {
    return Promise.reject(err);
  },
);
