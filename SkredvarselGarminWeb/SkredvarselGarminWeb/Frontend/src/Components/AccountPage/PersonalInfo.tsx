import { useUser } from "../../hooks/useUser";
import { Spinner } from "../ui/spinner";

export const PersonalInfo = () => {
  const { data: user, isLoading } = useUser();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center">
        <Spinner className="size-5" />
      </div>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <ul className="list-none">
      {user.name && <li>{user.name}</li>}
      <li>{user.email}</li>
    </ul>
  );
};
