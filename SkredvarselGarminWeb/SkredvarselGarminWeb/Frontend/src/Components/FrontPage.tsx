import { Features } from "./Features";
import { Button } from "./ui/button";

import bg from "../assets/bg.jpg?format=webp&as=source&imagetools";
import { CiqStoreButton } from "./CiqStoreButton";
import { useScrollPosition } from "../hooks/useScrollPosition";
import { ChevronIcon } from "./Icons/ChevronIcon";
import {
  FaApplePay,
  FaCreditCard,
  FaGooglePay,
  FaSkiing,
  FaSkiingNordic,
} from "react-icons/fa";
import { VippsIcon } from "./Icons/VippsIcon";
import { useUser } from "../hooks/useUser";
import { useCallback, useEffect, useState } from "react";
import { Outlet, useNavigate } from "react-router-dom";
import { cn } from "../lib/utils";

export const FrontPage = () => {
  const scrollPosition = useScrollPosition();
  const [isChevronVisible, setIsChevronVisible] = useState(false);
  const { data: user } = useUser();
  const navigate = useNavigate();

  useEffect(() => {
    if (scrollPosition !== 0) {
      setIsChevronVisible(false);
      return;
    }

    const animationFrame = requestAnimationFrame(() => {
      setIsChevronVisible(true);
    });

    return () => cancelAnimationFrame(animationFrame);
  }, [scrollPosition]);

  const onBuyClick = useCallback(
    (event: React.MouseEvent<HTMLButtonElement>) => {
      event.currentTarget.blur();

      if (user) {
        navigate("/account");
      } else {
        navigate("/subscribe");
      }
    },
    [navigate, user],
  );

  return (
    <>
      <div className="relative w-full h-[calc(100vh-5rem)] flex flex-col items-center">
        <img
          src={bg}
          alt=""
          className="absolute inset-0 w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-linear-to-r from-black/35 to-transparent" />
        <div className="relative z-10 flex-1 flex items-center justify-center">
          <div className="flex flex-col gap-6 max-w-4xl items-start p-4 md:p-8">
            <p className="text-white font-bold leading-tight text-3xl md:text-4xl">
              Skredvarsel for Garmin-klokker.
              <br />
              Oppdatert og tilgjengelig mens du er på tur.
            </p>
            <div className="flex items-center justify-center gap-2">
              <span className="text-white text-3xl font-extrabold">30 kr</span>
              <span className="text-xl text-white">/år</span>
            </div>
            <div className="flex flex-col gap-2 sm:flex-row sm:flex-nowrap sm:items-start">
              <div className="sm:shrink-0">
                <CiqStoreButton size="lg" />
              </div>
              <div className="flex flex-col gap-1 items-start sm:shrink-0">
                <Button
                  variant="green"
                  className="h-12 w-max justify-between rounded-md px-5 text-lg"
                  onClick={onBuyClick}
                >
                  <FaSkiingNordic className="size-5 shrink-0" />
                  <span className="flex-1 text-center">Kjøp abonnement</span>
                  <FaSkiing className="size-5 shrink-0" />
                </Button>
                <div className="flex items-center gap-2 px-5">
                  <VippsIcon title="Vipps" className="w-14 h-auto text-white" />
                  <FaCreditCard
                    title="Kort"
                    className="w-7 h-auto text-white"
                  />
                  <FaApplePay
                    title="Apple Pay"
                    className="w-9 h-auto text-white"
                  />
                  <FaGooglePay
                    title="Google Pay"
                    className="w-9 h-auto text-white"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
        <div
          className={cn(
            "relative z-10 transition-all duration-500",
            isChevronVisible
              ? "opacity-100 translate-y-0"
              : "opacity-0 translate-y-5",
          )}
        >
          <ChevronIcon className="text-white opacity-60 mb-5 w-12.5 h-12.5 md:w-25 md:h-25" />
        </div>
      </div>
      <Features />
      <Outlet />
    </>
  );
};
