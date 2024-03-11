import { getAccountFields } from "@/utils/objects";
import { useSuiClientQuery } from "@mysten/dapp-kit";
import { formatAddress } from "@mysten/sui.js/utils";
import { User } from "@nextui-org/react";

export default function UserAccount({ id }: { id: string }) {
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
      name={getAccountFields(data?.data)?.name}
      description={formatAddress(id)}
      avatarProps={{ name: "" }}
      className="ml-2"
    />
    // <p className="text-md ml-2">{getAccountFields(data?.data)?.name}</p>
    // <div>{JSON.stringify(getAccountFields(data?.data))}</div>
  );
}
