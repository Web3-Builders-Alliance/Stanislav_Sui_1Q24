import { useNetworkVariable } from "@/utils/networkConfig";
import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import { createContext, useEffect, useState } from "react";

export type AccountContextType = {
  accountId: string;
  refetch: () => void;
};

export const AccountContext = createContext<AccountContextType>({
  accountId: "",
  refetch: () => {},
});

export const AccountProvider = ({
  children,
}: {
  children: React.ReactNode;
}) => {
  const currentAccount = useCurrentAccount();
  const suigamesPackageId = useNetworkVariable("suigamesPackageId");

  const { data, refetch } = useSuiClientQuery("getOwnedObjects", {
    owner: currentAccount?.address!,
    filter: {
      StructType: `${suigamesPackageId}::account::Account`,
    },
    // options: { showType: true },
  });

  const [accountId, setAccountId] = useState("");
  useEffect(() => {
    // if (data === undefined || data.data.length === 0) {

    if (data === undefined || data.data.length === 0) {
      setAccountId("");
    } else {
      setAccountId(data.data[0].data!.objectId);
    }
  }, [data]);

  return (
    <AccountContext.Provider value={{ accountId, refetch }}>
      {children}
    </AccountContext.Provider>
  );
};
