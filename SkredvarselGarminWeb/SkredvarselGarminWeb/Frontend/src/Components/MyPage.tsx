import {
  Box,
  Button,
  Drawer,
  DrawerBody,
  DrawerCloseButton,
  DrawerContent,
  DrawerOverlay,
  Flex,
  FormControl,
  FormHelperText,
  FormLabel,
  Heading,
  Input,
  ListItem,
  Text,
  UnorderedList,
} from "@chakra-ui/react";
import { useLocation, useNavigate } from "react-router-dom";

export const MyPage = () => {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <Drawer
      isOpen={location.pathname == "/minSide"}
      onClose={() => navigate(-1)}
      size="md"
    >
      <DrawerOverlay />
      <DrawerContent>
        <DrawerCloseButton />

        <DrawerBody>
          <Heading size="md" mt={2} mb={8}>
            Min side
          </Heading>

          <Box mb={10}>
            <Heading size="sm" mb={2}>
              Abonnement
            </Heading>

            <Text mb={2}>
              Du har registrert et abonnement på appen. Tusen takk! Abonnementet
              fornyes automatisk 05.04.2023.
            </Text>

            <Button color="gray.500">Avslutt abonnement</Button>
          </Box>

          <Box mb={10}>
            <Heading size="sm" mb={2}>
              Klokker
            </Heading>

            <Text mb={4}>Du har ikke lagt til noen klokker.</Text>

            <Box pt={4} pl={4} pb={4} pr={8} bg="gray.100">
              <FormControl mb={2}>
                <FormLabel>Legg til klokke</FormLabel>
                <Flex gap={4}>
                  <Input colorScheme="red" bg="white" />
                  <Button colorScheme="blue">Legg til</Button>
                </Flex>

                <FormHelperText>
                  Skriv inn koden som står på klokka.
                </FormHelperText>
              </FormControl>
            </Box>
          </Box>

          <Box>
            <Heading size="sm" mb={2}>
              Personlige opplysninger
            </Heading>

            <Text>
              <UnorderedList listStyleType={"none"} marginInlineStart={0}>
                <ListItem>Dag Stuan</ListItem>
                <ListItem>D.Stuan@gmail.com</ListItem>
                <ListItem>90617353</ListItem>
              </UnorderedList>
            </Text>
          </Box>
        </DrawerBody>
      </DrawerContent>
    </Drawer>
  );
};
