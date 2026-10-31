import { useRouteError } from "react-router-dom";
import { useTranslation } from "react-i18next";

export default function ErrorPage() {
  const { t } = useTranslation();
  const error = useRouteError();
  console.error(error);

  return (
    <div id="error-page">
      <h1>{t(($) => $.error.title)}</h1>
      <p>{t(($) => $.error.unexpected)}</p>
    </div>
  );
}
