import { AdminPage } from "../Components/Admin/AdminPage";
import { RequireAdmin } from "../Components/Admin/RequireAdmin";

export const Component = () => (
  <RequireAdmin>
    <AdminPage />
  </RequireAdmin>
);
