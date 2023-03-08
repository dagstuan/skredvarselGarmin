import { Outlet } from "react-router-dom";

import { Footer } from "./Components/Footer";
import { Nav } from "./Components/Nav";
import { useScrollToTopOnNavigate } from "./hooks/useScrollToTopOnNavigate";

function App() {
  useScrollToTopOnNavigate();

  return (
    <>
      <Nav />
      <Outlet />
      <Footer />
    </>
  );
}

export default App;
