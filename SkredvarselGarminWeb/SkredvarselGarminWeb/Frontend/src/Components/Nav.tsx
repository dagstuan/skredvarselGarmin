import { Link as RouterLink, useNavigate } from "react-router-dom";
import { Button } from "./ui/button";
import { Heading } from "./ui/heading";
import { Spinner } from "./ui/spinner";

import avalancheIcon from "../assets/avalanche_icon.svg";
import { useUser } from "../hooks/useUser";

export const Nav = () => {
  const { data: user, isLoading } = useUser();
  const navigate = useNavigate();

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
        <RouterLink to="/" className="no-underline">
          <div className="flex gap-3 items-center">
            <img
              className="h-10"
              src={avalancheIcon}
              width={40}
              height={40}
              alt="Avalanche icon"
            />
            <Heading
              as="h1"
              className="text-xl md:text-3xl line-clamp-1 whitespace-nowrap text-ellipsis overflow-hidden"
            >
              <span className="sm:hidden">Skredvarsel</span>
              <span className="hidden sm:inline">Skredvarsel for Garmin</span>
            </Heading>
          </div>
        </RouterLink>

        <div>
          {isLoading ? (
            <Spinner className="size-8 text-gray-900" />
          ) : !user ? (
            <Button
              onClick={(event) => handleModalNavigation(event, "/login")}
              variant="blue"
            >
              Logg inn
            </Button>
          ) : (
            <div className="flex gap-4">
              {user.isAdmin && (
                <Button
                  nativeButton={false}
                  variant="blue"
                  render={<RouterLink to="/admin" />}
                >
                  Admin
                </Button>
              )}
              <Button
                nativeButton={false}
                variant="blue"
                render={
                  <RouterLink
                    to="/account"
                    onClick={(event) => event.currentTarget.blur()}
                  />
                }
              >
                Min side
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
