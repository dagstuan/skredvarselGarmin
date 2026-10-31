import { useState, useRef, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { type AppRouteKey, usePathForCurrentLanguage } from "../routes";

export const useNavigateOnClose = (target: AppRouteKey) => {
  const navigate = useNavigate();
  const pathFor = usePathForCurrentLanguage();

  const [isClosing, setIsClosing] = useState<boolean>(false);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  const onClose = useCallback(() => {
    setIsClosing(true);
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
    timeoutRef.current = setTimeout(() => {
      navigate(pathFor(target));
    }, 200);
  }, [navigate, pathFor, target]);

  return {
    isClosing,
    onClose,
  };
};
