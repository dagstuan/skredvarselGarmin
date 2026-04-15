import { AxiosError } from "axios";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { useAddWatch, useWatches } from "../../hooks/useWatches";
import { ProblemDetails } from "../../types";
import { Heading } from "../ui/heading";
import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { Label } from "../ui/label";
import { Spinner } from "../ui/spinner";
import { Watch } from "./Watch";

export const Watches = () => {
  const { t } = useTranslation();
  const { data: watches, isLoading } = useWatches();
  const addWatch = useAddWatch();

  const [error, setError] = useState<string | undefined>();
  const [key, setKey] = useState("");

  const clearError = () => setError(undefined);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    clearError();
    setKey(e.target.value);
  };

  useEffect(() => {
    if (addWatch.isError) {
      setError(
        ((addWatch.error as AxiosError).response?.data as ProblemDetails)
          .detail,
      );
    }
  }, [addWatch.isError, addWatch.error, setError]);

  useEffect(() => {
    if (addWatch.isSuccess) {
      setKey("");
    }
  }, [addWatch.isSuccess]);

  const handleAddSubmit = (evt: React.FormEvent<HTMLFormElement>) => {
    evt.preventDefault();

    if (!key) {
      setError(t(($) => $.account.watches.codeRequired));
    } else {
      clearError();
      addWatch.mutate(key);
    }
  };

  const isError = !!error;

  return (
    <div>
      <Heading as="h3" className="mb-2 text-xl">
        {t(($) => $.account.watchesHeading)}
      </Heading>

      {isLoading ? (
        <div className="flex items-center justify-center">
          <Spinner className="size-5" />
        </div>
      ) : (
        <>
          {!watches || watches.length < 1 ? (
            <p className="mb-4">{t(($) => $.account.watches.none)}</p>
          ) : (
            <>
              <ul className="mb-4 list-none">
                {watches.map((w) => (
                  <li key={w.id}>
                    <Watch watch={w} />
                  </li>
                ))}
              </ul>
            </>
          )}
        </>
      )}

      <div className="pt-4 pl-4 pb-4 pr-8 bg-gray-100 rounded-md">
        <form onSubmit={handleAddSubmit}>
          <div className="mb-2">
            <Label htmlFor="watch-key" className="mb-2 block">
              {t(($) => $.account.watches.addWatchLabel)}
            </Label>
            <div className="flex gap-4">
              <Input
                id="watch-key"
                className="bg-white"
                value={key}
                onChange={handleInputChange}
              />
              <Button
                variant="blue"
                type="submit"
                disabled={addWatch.isPending}
              >
                {t(($) => $.account.watches.add)}
              </Button>
            </div>
            {!isError ? (
              <p className="text-sm text-muted-foreground mt-2">
                {t(($) => $.account.watches.help)}
              </p>
            ) : (
              <p className="text-sm text-red-600 mt-2">{error}</p>
            )}
          </div>
        </form>
      </div>
    </div>
  );
};
