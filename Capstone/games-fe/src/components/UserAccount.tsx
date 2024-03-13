import { getAccountFields } from "@/utils/objects";
import { useSuiClientQuery } from "@mysten/dapp-kit";
import { formatAddress } from "@mysten/sui.js/utils";
import { Snippet, User } from "@nextui-org/react";

export default function UserAccount({
  id,
  className,
}: {
  id: string;
  className?: string;
}) {
  const { data, isPending, error, refetch } = useSuiClientQuery("getObject", {
    id,
    options: {
      showContent: true,
      // showOwner: true,
      // showType: true,
    },
  });

  if (isPending) return <div>Loading...</div>;
  if (error) return <div>Error</div>;

  if (!data.data) return;

  return (
    <User
      name={getAccountFields(data.data)?.name}
      description={
        <Snippet hideSymbol variant="flat" size="sm" codeString={id}>
          {formatAddress(id)}
        </Snippet>
      }
      avatarProps={{ name: "" }}
      className={className}
    />
  );
}
