import { Separator } from "./ui/separator";

type OrDividerProps = {
  text?: string;
  bgClassName?: string;
};

export const OrDivider = ({
  text = "Eller",
  bgClassName = "bg-background",
}: OrDividerProps) => {
  return (
    <div className="mb-2 mt-2 relative whitespace-nowrap">
      <Separator />
      <div
        className={`absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 px-4 ${bgClassName}`}
      >
        {text}
      </div>
    </div>
  );
};
