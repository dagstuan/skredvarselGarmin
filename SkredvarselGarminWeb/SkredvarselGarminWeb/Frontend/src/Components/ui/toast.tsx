import { Toast } from "@base-ui/react/toast";
import {
  CheckCircle2Icon,
  CircleAlertIcon,
  InfoIcon,
  XIcon,
} from "lucide-react";

import { toastManager } from "../../lib/toast";
import { cn } from "@/lib/utils";

const getToastClasses = (type?: string) => {
  switch (type) {
    case "success":
      return "border-brand-green-500/20 bg-card";
    case "error":
      return "border-destructive/20 bg-card";
    default:
      return "border-border bg-card";
  }
};

const getToastIcon = (type?: string) => {
  switch (type) {
    case "success":
      return CheckCircle2Icon;
    case "error":
      return CircleAlertIcon;
    default:
      return InfoIcon;
  }
};

const getToastIconClasses = (type?: string) => {
  switch (type) {
    case "success":
      return "bg-brand-green-500 text-white";
    case "error":
      return "bg-destructive text-white";
    default:
      return "bg-brand-blue-500 text-white";
  }
};

function ToasterViewport() {
  const { toasts } = Toast.useToastManager();

  return (
    <Toast.Portal>
      <Toast.Viewport className="pointer-events-none fixed top-4 right-4 z-60 flex w-[calc(100vw-2rem)] max-w-sm flex-col gap-3 outline-none sm:top-6 sm:right-6">
        {toasts.map((toast) => (
          <Toast.Root
            key={toast.id}
            toast={toast}
            className="pointer-events-auto transition-all duration-200 data-starting-style:translate-y-2 data-starting-style:scale-[0.98] data-starting-style:opacity-0 data-ending-style:translate-y-2 data-ending-style:scale-[0.98] data-ending-style:opacity-0"
          >
            <Toast.Content
              className={cn(
                "grid grid-cols-[auto_1fr_auto] items-start gap-3 rounded-2xl border p-4 shadow-[0_18px_45px_-20px_rgba(15,23,42,0.35)]",
                getToastClasses(toast.type),
              )}
            >
              {(() => {
                const Icon = getToastIcon(toast.type);

                return (
                  <div
                    className={cn(
                      "flex size-10 items-center justify-center rounded-full shadow-sm",
                      getToastIconClasses(toast.type),
                    )}
                  >
                    <Icon className="size-5" />
                  </div>
                );
              })()}

              <div className="min-w-0 space-y-1 pt-0.5">
                {toast.title ? (
                  <Toast.Title className="text-base font-semibold tracking-tight text-foreground">
                    {toast.title}
                  </Toast.Title>
                ) : null}
                {toast.description ? (
                  <Toast.Description className="text-sm leading-5 text-muted-foreground">
                    {toast.description}
                  </Toast.Description>
                ) : null}
              </div>

              <Toast.Close className="text-muted-foreground hover:text-foreground hover:bg-muted inline-flex size-8 items-center justify-center rounded-full transition-colors cursor-pointer">
                <XIcon className="size-4" />
                <span className="sr-only">Lukk</span>
              </Toast.Close>
            </Toast.Content>
          </Toast.Root>
        ))}
      </Toast.Viewport>
    </Toast.Portal>
  );
}

function Toaster({ children }: { children: React.ReactNode }) {
  return (
    <Toast.Provider toastManager={toastManager} limit={4}>
      {children}
      <ToasterViewport />
    </Toast.Provider>
  );
}

export { Toaster };
