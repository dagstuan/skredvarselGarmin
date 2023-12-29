import { useState, useRef, useCallback } from "react";
import { useNavigate } from "react-router-dom";

export const useNavigateOnClose = (target: string) => {
  const navigate = useNavigate();

  const [isClosing, setIsClosing] = useState<boolean>(false);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  const onClose = useCallback(() => {
    setIsClosing(true);
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
    timeoutRef.current = setTimeout(() => {
      navigate(target);
    }, 200);
  }, [navigate]);

  return {
    isClosing,
    onClose,
  };
};
