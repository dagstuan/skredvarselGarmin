import { Card, CardContent } from "./ui/card";
import { Heading } from "./ui/heading";
import { cn } from "../lib/utils";

type FeatureProps = {
  imgUrl: string;
  imgWidth: number;
  imgHeight: number;
  heading: string;
  text: string;
};

export const Feature = ({
  imgUrl,
  imgWidth,
  imgHeight,
  heading,
  text,
}: FeatureProps) => {
  return (
    <Card className="bg-white shadow-2xl rounded-md overflow-hidden sm:max-w-56">
      <div className="bg-slate-100">
        <img
          className="w-full object-cover"
          width={imgWidth}
          height={imgHeight}
          src={imgUrl}
          alt={text}
        />
      </div>
      <CardContent className="space-y-2 p-6">
        <Heading as="h3" size="md" className="text-gray-700">
          {heading}
        </Heading>
        <p className="text-gray-600">{text}</p>
      </CardContent>
    </Card>
  );
};
