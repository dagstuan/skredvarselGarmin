import { useEffect, useState } from "react";
import {
  Link as RouterLink,
  useNavigate,
  useSearchParams,
} from "react-router-dom";
import { useNavigateOnClose } from "../../hooks/useNavigateOnClose";
import { useUser } from "../../hooks/useUser";
import { useAddWatch } from "../../hooks/useWatches";
import { Drawer, DrawerPopup, DrawerClose } from "../ui/drawer";
import { Heading } from "../ui/heading";
import { Button } from "../ui/button";
import { PersonalInfo } from "./PersonalInfo";
import { Subscription } from "./Subscription";
import { Watches } from "./Watches";

export const AccountPage = () => {
  const { data: user, isLoading: isLoadingUser } = useUser();

  const navigate = useNavigate();

  const { isClosing, onClose } = useNavigateOnClose("/");

  useEffect(() => {
    if (!user && !isLoadingUser) {
      navigate("/login");
    }
  }, [user, isLoadingUser]);

  const [searchParams, setSearchParams] = useSearchParams();
  const watchKey = searchParams.get("watchKey");

  const { mutate: mutateAddWatch, isPending: isAddWatchPending } = useAddWatch(
    () => {
      searchParams.delete("watchKey");
      setSearchParams(searchParams, {
        replace: true,
        preventScrollReset: true,
      });
    },
  );

  useEffect(() => {
    if (user && watchKey && !isAddWatchPending) {
      mutateAddWatch(watchKey);
    }
  }, [mutateAddWatch, isAddWatchPending, user, watchKey]);

  return (
    <Drawer
      open={!isClosing}
      onOpenChange={(open) => !open && onClose()}
      direction="right"
    >
      <DrawerPopup className="p-4 focus:outline-none">
        <DrawerClose className="absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none data-[state=open]:bg-secondary">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
            className="h-4 w-4"
          >
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
          <span className="sr-only">Close</span>
        </DrawerClose>

        <div className="flex flex-col gap-4">
          <Heading size="md" className="mt-2 mb-4">
            Min side
          </Heading>

          <p className="mb-6">
            Lurer du på noe? Se{" "}
            <RouterLink to="/faq" className="text-blue-600 hover:underline">
              ofte stilte spørsmål
            </RouterLink>
            .
          </p>

          <div className="mb-6">
            <Heading size="sm" className="mb-2">
              Abonnement
            </Heading>

            <Subscription />
          </div>

          <div className="mb-6">
            <Watches />
          </div>

          <div className="mb-6">
            <Heading size="sm" className="mb-2">
              Personlige opplysninger
            </Heading>

            <PersonalInfo />
          </div>

          <div className="mb-5">
            <Button
              render={(props) => <a {...props} href="/logout" />}
              variant="blue"
              className="rounded"
            >
              Logg ut
            </Button>
          </div>
        </div>
      </DrawerPopup>
    </Drawer>
  );
};
