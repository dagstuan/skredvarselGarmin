import {
  Heading,
  UnorderedList,
  ListItem,
  FormControl,
  FormLabel,
  Flex,
  Input,
  Button,
  FormHelperText,
  Box,
  Text,
  Spinner,
  FormErrorMessage,
} from "@chakra-ui/react";
import { AxiosError } from "axios";
import { useEffect, useState } from "react";
import { useAddWatch, useWatches } from "../../hooks/useWatches";
import { ProblemDetails } from "../../types";
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
        ((addWatch.error as AxiosError).response?.data as ProblemDetails).detail
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
    <>
      <Heading size="sm" mb={2}>
        Klokker
      </Heading>

      {isLoading ? (
        <Spinner />
      ) : (
        <>
          {!watches || watches.length < 1 ? (
            <Text mb={4}>Du har ikke lagt til noen klokker.</Text>
          ) : (
            <>
              <UnorderedList mb={4} listStyleType="none" marginInlineStart={0}>
                {watches.map((w) => (
                  <ListItem key={w.id}>
                    <Watch watch={w} />
                  </ListItem>
                ))}
              </UnorderedList>
            </>
          )}
        </>
      )}

      <Box pt={4} pl={4} pb={4} pr={8} bg="gray.100">
        <form onSubmit={handleAddSubmit}>
          <FormControl mb={2} isInvalid={isError}>
            <FormLabel>Legg til klokke</FormLabel>
            <Flex gap={4}>
              <Input
                colorScheme="red"
                bg="white"
                value={key}
                onChange={handleInputChange}
              />
              <Button
                colorScheme="blue"
                type="submit"
                isDisabled={addWatch.isLoading}
              >
                Legg til
              </Button>
            </Flex>
            {!isError ? (
              <FormHelperText>
                Skriv inn koden som står på klokka.
              </FormHelperText>
            ) : (
              <FormErrorMessage>{error}</FormErrorMessage>
            )}
          </FormControl>
        </form>
      </Box>
    </>
  );
};
