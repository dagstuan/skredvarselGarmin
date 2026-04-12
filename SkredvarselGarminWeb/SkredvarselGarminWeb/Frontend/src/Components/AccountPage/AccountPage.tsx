import { useEffect } from "react";
import { XIcon } from "lucide-react";
import {
  Link as RouterLink,
  useNavigate,
  useSearchParams,
} from "react-router-dom";
import { useNavigateOnClose } from "../../hooks/useNavigateOnClose";
import { useUser } from "../../hooks/useUser";
import { useAddWatch } from "../../hooks/useWatches";
import {
  Drawer,
  DrawerPopup,
  DrawerClose,
  DrawerTitle,
  DrawerDescription,
} from "../ui/drawer";
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
    undefined,
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
      autoFocus
      open={!isClosing}
      onOpenChange={(open) => !open && onClose()}
      direction="right"
    >
      <DrawerPopup className="focus:outline-none w-full! overflow-hidden p-0">
        <DrawerTitle className="sr-only">Min side</DrawerTitle>
        <DrawerDescription className="sr-only">
          Administrer abonnement, klokker og personlige opplysninger.
        </DrawerDescription>
        <DrawerClose className="absolute right-3 top-3 inline-flex items-center justify-center size-9 rounded-md cursor-pointer opacity-70 transition-all hover:opacity-100 hover:bg-muted focus:outline-none disabled:pointer-events-none">
          <XIcon className="size-5" />
          <span className="sr-only">Close</span>
        </DrawerClose>
        <div
          className="overflow-y-auto overscroll-contain h-full p-4"
          data-vaul-no-drag
        >
          <div className="flex flex-col gap-4">
            <Heading as="h2" className="mt-2 mb-4 text-xl">
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
              <Heading as="h3" className="mb-2 text-xl">
                Abonnement
              </Heading>

              <Subscription />
            </div>

            <div className="mb-6">
              <Watches />
            </div>

            <div className="mb-6">
              <Heading as="h3" className="mb-2 text-xl">
                Personlige opplysninger
              </Heading>

              <PersonalInfo />
            </div>

            <div className="mb-5">
              <Button
                nativeButton={false}
                render={(props) => <a {...props} href="/logout" />}
                variant="blue"
              >
                Logg ut
              </Button>
            </div>
          </div>
        </div>
      </DrawerPopup>
    </Drawer>
  );
};
