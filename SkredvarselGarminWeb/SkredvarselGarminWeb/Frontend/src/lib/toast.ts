import type { ReactNode } from "react";
import { Toast } from "@base-ui/react/toast";

type ToastType = "success" | "error" | "info";

type ShowToastOptions = {
  title?: ReactNode;
  description?: ReactNode;
  type?: ToastType;
  timeout?: number;
};

export const toastManager = Toast.createToastManager();

export const toast = {
  show({ title, description, type = "info", timeout }: ShowToastOptions) {
    return toastManager.add({
      title,
      description,
      type,
      timeout,
      priority: type === "error" ? "high" : "low",
    });
  },
  success(title: ReactNode, description?: ReactNode) {
    return toastManager.add({
      title,
      description,
      type: "success",
      priority: "low",
    });
  },
  error(title: ReactNode, description?: ReactNode) {
    return toastManager.add({
      title,
      description,
      type: "error",
      priority: "high",
    });
  },
  info(title: ReactNode, description?: ReactNode) {
    return toastManager.add({
      title,
      description,
      type: "info",
      priority: "low",
    });
  },
};
