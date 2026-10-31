import { useTranslation } from "react-i18next";
import { useLocation, useNavigate } from "react-router-dom";
import { cn } from "@/lib/utils";
import { Button } from "./ui/button";
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTrigger,
} from "./ui/popover";
import { supportedLanguages, type AppLanguage } from "../i18n/resources";
import {
  buildLocalizedPath,
  useCurrentLanguage,
  useCurrentRouteKey,
} from "../routes";

const languageOptions: Record<AppLanguage, { label: string; flag: string }> = {
  no: {
    label: "Norsk",
    flag: "🇳🇴",
  },
  en: {
    label: "English",
    flag: "🇬🇧",
  },
  sv: {
    label: "Svenska",
    flag: "🇸🇪",
  },
};

type LanguageSwitcherProps = {
  buttonClassName?: string;
};

export const LanguageSwitcher = ({
  buttonClassName,
}: LanguageSwitcherProps = {}) => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const currentLanguage = useCurrentLanguage();
  const currentRouteKey = useCurrentRouteKey();
  const currentOption = languageOptions[currentLanguage];

  return (
    <Popover>
      <PopoverTrigger
        render={
          <Button
            type="button"
            variant="ghost"
            size="default"
            className={cn(
              "h-10 min-w-10 rounded-md px-3 text-2xl",
              buttonClassName,
            )}
            aria-label={t(($) => $.languageSwitcher.label)}
            title={currentOption.label}
          />
        }
      >
        <span className="leading-none" aria-hidden="true">
          {currentOption.flag}
        </span>
      </PopoverTrigger>
      <PopoverContent
        collisionAvoidance={{ align: "shift" }}
        aria-label={t(($) => $.languageSwitcher.label)}
      >
        {supportedLanguages.map((language) => {
          const isCurrentLanguage = language === currentLanguage;
          const option = languageOptions[language];

          return (
            <PopoverClose
              key={language}
              lang={language === "no" ? "nb" : language}
              aria-current={isCurrentLanguage ? "true" : undefined}
              className={cn(
                "flex w-full cursor-pointer items-center gap-3 rounded-lg px-3 py-2 text-left text-sm outline-none transition-colors hover:bg-muted focus-visible:bg-muted",
                isCurrentLanguage && "bg-muted",
              )}
              onClick={() => {
                if (isCurrentLanguage) {
                  return;
                }

                navigate(
                  buildLocalizedPath(language, currentRouteKey, {
                    search: location.search,
                    hash: location.hash,
                  }),
                );
              }}
            >
              <span className="text-lg leading-none" aria-hidden="true">
                {option.flag}
              </span>
              <span className="font-medium">{option.label}</span>
            </PopoverClose>
          );
        })}
      </PopoverContent>
    </Popover>
  );
};
