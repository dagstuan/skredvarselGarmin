import { GlobeIcon, CheckIcon, ChevronDownIcon } from "lucide-react";
import { useTranslation } from "react-i18next";
import { useLocation, useNavigate } from "react-router-dom";
import { Button } from "./ui/button";
import { Menu, MenuContent, MenuItem, MenuTrigger } from "./ui/menu";
import { supportedLanguages, type AppLanguage } from "../i18n/resources";
import {
  buildLocalizedPath,
  useCurrentLanguage,
  useCurrentRouteKey,
} from "../routes";

const languageOptions: Record<
  AppLanguage,
  { label: string; shortLabel: string; description: string }
> = {
  no: {
    label: "Norsk Bokmal",
    shortLabel: "NO",
    description: "Norsk versjon",
  },
  en: {
    label: "English",
    shortLabel: "EN",
    description: "English version",
  },
  sv: {
    label: "Svenska",
    shortLabel: "SV",
    description: "Svensk version",
  },
};

export const LanguageSwitcher = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const currentLanguage = useCurrentLanguage();
  const currentRouteKey = useCurrentRouteKey();

  return (
    <Menu>
      <MenuTrigger
        render={
          <Button
            variant="outline"
            size="sm"
            className="gap-2 rounded-full border-gray-300 bg-white px-3 shadow-sm"
          />
        }
        aria-label={t(($) => $.languageSwitcher.label)}
      >
        <GlobeIcon className="size-4" />
        <span className="text-xs font-semibold">
          {languageOptions[currentLanguage].shortLabel}
        </span>
        <ChevronDownIcon className="size-4 text-muted-foreground" />
      </MenuTrigger>
      <MenuContent align="end" side="bottom">
        {supportedLanguages.map((language) => {
          const isCurrentLanguage = language === currentLanguage;
          const option = languageOptions[language];

          return (
            <MenuItem
              key={language}
              onClick={() => {
                navigate(
                  buildLocalizedPath(language, currentRouteKey, {
                    search: location.search,
                    hash: location.hash,
                  }),
                );
              }}
            >
              <div className="flex min-w-0 flex-1 flex-col">
                <span className="font-medium">{option.label}</span>
                <span className="text-xs text-muted-foreground">
                  {option.description}
                </span>
              </div>
              {isCurrentLanguage && <CheckIcon className="size-4 text-brand-green-500" />}
            </MenuItem>
          );
        })}
      </MenuContent>
    </Menu>
  );
};