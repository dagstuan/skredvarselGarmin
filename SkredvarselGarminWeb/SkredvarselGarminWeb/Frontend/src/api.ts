import axios from "axios";

export const api = axios.create({
  baseURL: "/",
  timeout: 30000,
});
