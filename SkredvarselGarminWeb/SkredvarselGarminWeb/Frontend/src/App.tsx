import { Box, Flex } from "@chakra-ui/react";
import { Outlet } from "react-router-dom";

import { Footer } from "./Components/Footer";
import { Nav } from "./Components/Nav";
import { useScrollToTopOnNavigate } from "./hooks/useScrollToTopOnNavigate";

function App() {
  useScrollToTopOnNavigate();

  return (
    <Flex minH="100vh" flexDir="column">
      <Nav />
      <Box w="100%">
        <Outlet />
      </Box>
      <Box mt="auto">
        <Footer />
      </Box>
    </Flex>
  );
}

export default App;
