import axios, { AxiosError } from "axios";

export const api = axios.create({
  baseURL: "/",
  timeout: 30000,
});

api.interceptors.response.use(
  (r) => r,
  async (err: AxiosError) => {
    if (err.response?.status == 401) {
      window.location.reload();
    }

    return Promise.reject(err);
  }
);
