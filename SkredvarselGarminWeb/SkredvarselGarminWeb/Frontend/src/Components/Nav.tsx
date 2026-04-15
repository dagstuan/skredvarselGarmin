import { Link as RouterLink, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { Button } from "./ui/button";
import { Heading } from "./ui/heading";
import { Spinner } from "./ui/spinner";

import avalancheIcon from "../assets/avalanche_icon.svg";
import { useUser } from "../hooks/useUser";
import { LanguageSwitcher } from "./LanguageSwitcher";
import { usePathForCurrentLanguage } from "../routes";

export const Nav = () => {
  const { t } = useTranslation();
  const { data: user, isLoading } = useUser();
  const navigate = useNavigate();
  const pathFor = usePathForCurrentLanguage();

  const handleModalNavigation = (
    event: React.MouseEvent<HTMLElement>,
    target: string,
  ) => {
    event.currentTarget.blur();
    navigate(target);
  };

  return (
    <div className="flex justify-center px-4 bg-gray-100">
      <div className="w-full max-w-full h-20 flex items-center gap-4 justify-between">
        <RouterLink to={pathFor("home")} className="no-underline">
          <div className="flex gap-3 items-center">
            <img
              className="h-10"
              src={avalancheIcon}
              width={40}
              height={40}
              alt={t(($) => $.nav.iconAlt)}
            />
            <Heading
              as="h1"
              className="text-xl md:text-3xl line-clamp-1 whitespace-nowrap text-ellipsis overflow-hidden"
            >
              <span className="sm:hidden">{t(($) => $.nav.shortTitle)}</span>
              <span className="hidden sm:inline">{t(($) => $.nav.title)}</span>
            </Heading>
          </div>
        </RouterLink>

        <div className="flex items-center gap-3">
          <LanguageSwitcher />
          {isLoading ? (
            <Spinner className="size-8 text-gray-900" />
          ) : !user ? (
            <Button
              onClick={(event) => handleModalNavigation(event, pathFor("login"))}
              variant="blue"
            >
              {t(($) => $.nav.login)}
            </Button>
          ) : (
            <div className="flex gap-4">
              {user.isAdmin && (
                <Button
                  nativeButton={false}
                  variant="blue"
                  render={<RouterLink to={pathFor("admin")} />}
                >
                  {t(($) => $.nav.admin)}
                </Button>
              )}
              <Button
                nativeButton={false}
                variant="blue"
                render={
                  <RouterLink
                    to={pathFor("account")}
                    onClick={(event) => event.currentTarget.blur()}
                  />
                }
              >
                {t(($) => $.nav.account)}
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
