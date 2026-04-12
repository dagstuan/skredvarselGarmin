import { Outlet } from "react-router-dom";

import { Footer } from "./Components/Footer";
import { Nav } from "./Components/Nav";
import { useScrollToTopOnNavigate } from "./hooks/useScrollToTopOnNavigate";

function App() {
  useScrollToTopOnNavigate();

  return (
    <div className="min-h-screen flex flex-col">
      <Nav />
      <div className="w-full">
        <Outlet />
      </div>
      <div className="mt-auto">
        <Footer />
      </div>
    </div>
  );
}

export default App;
