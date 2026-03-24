import { AxiosError } from "axios";
import { useEffect, useState } from "react";
import { useAddWatch, useWatches } from "../../hooks/useWatches";
import { ProblemDetails } from "../../types";
import { Heading } from "../ui/heading";
import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { Label } from "../ui/label";
import { Watch } from "./Watch";

export const Watches = () => {
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
      setError("Du må skrive en kode.");
    } else {
      clearError();
      addWatch.mutate(key);
    }
  };

  const isError = !!error;

  return (
    <div>
      <Heading size="sm" className="mb-2">
        Klokker
      </Heading>

      {isLoading ? (
        <div className="flex items-center justify-center">
          <svg
            className="animate-spin h-5 w-5"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            ></circle>
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
        </div>
      ) : (
        <>
          {!watches || watches.length < 1 ? (
            <p className="mb-4">Du har ikke lagt til noen klokker.</p>
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

      <div className="pt-4 pl-4 pb-4 pr-8 bg-gray-100 rounded">
        <form onSubmit={handleAddSubmit}>
          <div className="mb-2">
            <Label htmlFor="watch-key" className="mb-2 block">
              Legg til klokke
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
                Legg til
              </Button>
            </div>
            {!isError ? (
              <p className="text-sm text-muted-foreground mt-2">
                Skriv inn koden som står på klokka når du starter appen.
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
