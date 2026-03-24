import { Link as RouterLink, useNavigate } from "react-router-dom";
import { Button } from "./ui/button";
import { Heading } from "./ui/heading";

import avalancheIcon from "../assets/avalanche_icon.svg";
import { useUser } from "../hooks/useUser";

export const Nav = () => {
  const { data: user, isLoading } = useUser();
  const navigate = useNavigate();

  const isMobile = window.innerWidth < 640;
  const heading = isMobile ? "Skredvarsel" : "Skredvarsel for Garmin";
  const headingSize = window.innerWidth < 768 ? "sm" : "lg";

  return (
    <div className="flex justify-center px-4 bg-gray-100">
      <div className="w-full max-w-full h-20 flex items-center justify-between">
        <RouterLink to="/" className="no-underline">
          <div className="flex gap-3 items-center">
            <img
              className="h-10"
              src={avalancheIcon}
              width={40}
              height={40}
              alt="Avalanche icon"
            />
            <Heading as="h1" size={headingSize} className="line-clamp-1">
              {heading}
            </Heading>
          </div>
        </RouterLink>

        <div>
          {isLoading ? (
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900" />
          ) : !user ? (
            <Button
              onClick={() => navigate("/login")}
              variant="blue"
              className="rounded"
            >
              Logg inn
            </Button>
          ) : (
            <div className="flex gap-4">
              {user.isAdmin && (
                <Button
                  variant="blue"
                  className="rounded"
                  render={<RouterLink to="/admin" />}
                >
                  Admin
                </Button>
              )}
              <Button
                variant="blue"
                className="rounded"
                render={<RouterLink to="/account" />}
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
