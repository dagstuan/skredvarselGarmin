import { BsWatch, BsTrash } from "react-icons/bs";
import { useRemoveWatch } from "../../hooks/useWatches";
import { Watch as WatchType } from "../../types";
import { Button } from "../ui/button";

export type WatchProps = {
  watch: WatchType;
};

export const Watch = ({ watch: { name, id } }: WatchProps) => {
  const removeWatch = useRemoveWatch();

  return (
    <div className="flex items-center py-2 px-4">
      <div className="flex items-center justify-center w-8 h-8 rounded-full">
        <BsWatch className="w-5 h-5" />
      </div>
      <p className="flex-1 font-semibold">
        {name}
      </p>
      <Button
        variant="red"
        size="icon"
        onClick={() => removeWatch.mutate(id)}
        aria-label="delete"
      >
        <BsTrash />
      </Button>
    </div>
  );
};
