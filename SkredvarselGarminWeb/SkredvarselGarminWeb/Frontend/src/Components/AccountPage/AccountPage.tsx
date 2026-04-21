import { useEffect, useRef } from "react";
import { XIcon } from "lucide-react";
import {
  Link as RouterLink,
  useNavigate,
  useSearchParams,
} from "react-router-dom";
import { useTranslation } from "react-i18next";
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
import { usePathForCurrentLanguage } from "../../routes";

export const AccountPage = () => {
  const { t } = useTranslation();
  const { data: user, isLoading: isLoadingUser } = useUser();
  const pathFor = usePathForCurrentLanguage();

  const navigate = useNavigate();

  const { isClosing, onClose } = useNavigateOnClose("home");

  useEffect(() => {
    if (!user && !isLoadingUser) {
      navigate(pathFor("login"));
    }
  }, [isLoadingUser, navigate, pathFor, user]);

  const [searchParams, setSearchParams] = useSearchParams();
  const watchKey = searchParams.get("watchKey");
  const handledWatchKeyRef = useRef<string | null>(null);

  const { mutate: mutateAddWatch } = useAddWatch(undefined, () => {
    searchParams.delete("watchKey");
    setSearchParams(searchParams, {
      replace: true,
      preventScrollReset: true,
    });
  });

  useEffect(() => {
    if (!watchKey) {
      handledWatchKeyRef.current = null;
      return;
    }

    if (!user || handledWatchKeyRef.current === watchKey) {
      return;
    }

    handledWatchKeyRef.current = watchKey;
    mutateAddWatch(watchKey);
  }, [mutateAddWatch, user, watchKey]);

  return (
    <Drawer
      autoFocus
      open={!isClosing}
      onOpenChange={(open) => !open && onClose()}
      direction="right"
    >
      <DrawerPopup
        className="focus:outline-none w-full overflow-hidden p-0 select-text"
        onPointerDownOutside={(event) => {
          if (
            event.target instanceof Element &&
            event.target.closest("[data-toast-viewport='true']")
          ) {
            event.preventDefault();
          }
        }}
      >
        <DrawerTitle className="sr-only">{t(($) => $.account.pageTitle)}</DrawerTitle>
        <DrawerDescription className="sr-only">
          {t(($) => $.account.srDescription)}
        </DrawerDescription>
        <DrawerClose className="absolute right-3 top-3 inline-flex items-center justify-center size-9 rounded-md cursor-pointer opacity-70 transition-all hover:opacity-100 hover:bg-muted focus:outline-none disabled:pointer-events-none">
          <XIcon className="size-5" />
          <span className="sr-only">{t(($) => $.common.close)}</span>
        </DrawerClose>
        <div
          className="overflow-y-auto h-full p-4 select-text"
          data-vaul-no-drag
        >
          <div className="flex flex-col gap-4">
            <Heading as="h2" className="mt-2 mb-4 text-xl">
              {t(($) => $.account.pageTitle)}
            </Heading>

            <p className="mb-6">
              {t(($) => $.account.faqPromptPrefix)}
              <RouterLink to={pathFor("faq")} className="text-blue-600 hover:underline">
                {t(($) => $.account.faqPromptLink)}
              </RouterLink>
              {t(($) => $.account.faqPromptSuffix)}
            </p>

            <div className="mb-6">
              <Heading as="h3" className="mb-2 text-xl">
                {t(($) => $.account.subscriptionHeading)}
              </Heading>

              <Subscription />
            </div>

            <div className="mb-6">
              <Watches />
            </div>

            <div className="mb-6">
              <Heading as="h3" className="mb-2 text-xl">
                {t(($) => $.account.personalInfoHeading)}
              </Heading>

              <PersonalInfo />
            </div>

            <div className="mb-5">
              <Button
                nativeButton={false}
                render={(props) => <a {...props} href="/logout" />}
                variant="blue"
              >
                {t(($) => $.account.logout)}
              </Button>
            </div>
          </div>
        </div>
      </DrawerPopup>
    </Drawer>
  );
};
