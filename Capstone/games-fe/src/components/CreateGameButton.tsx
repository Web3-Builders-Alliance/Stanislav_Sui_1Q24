import { useNetworkVariable } from "@/utils/networkConfig";
import {
  useCurrentAccount,
  useSuiClientQuery,
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { SUI_DEVNET_CHAIN } from "@mysten/wallet-standard";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui.js/utils";

import { Button } from "@nextui-org/react";
import { useState } from "react";

export default function CreateGameButton({
  classname,
  onCreate,
}: {
  classname?: string;
  onCreate?: () => void;
}) {
  const currentAccount = useCurrentAccount();
  const suigamesPackageId = useNetworkVariable("suigamesPackageId");
  const hexPackageId = useNetworkVariable("hexgamePackageId");
  const gamesPackId = useNetworkVariable("gamespackId");
  const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
  const client = useSuiClient();

  const { data } = useSuiClientQuery("getOwnedObjects", {
    owner: currentAccount?.address!,
    filter: {
      StructType: `${suigamesPackageId}::account::Account`,
    },
  });

  const [isCreating, setIsCreating] = useState(false);

  const createGame = async () => {
    if (!currentAccount) {
      return;
    }

    if (!data) {
      return;
    }

    setIsCreating(true);

    const txb = new TransactionBlock();

    let accountId = data.data[0].data!.objectId;
    let [coin] = txb.splitCoins(txb.gas, [0]);

    txb.moveCall({
      arguments: [
        txb.object(gamesPackId),
        txb.object(accountId),
        txb.pure(
          "0x0000000000000000000000000000000000000000000000000000000000000000"
        ),
        coin,
        txb.object(SUI_CLOCK_OBJECT_ID),
      ],
      target: `${hexPackageId}::main::create_game`,
    });

    signAndExecute(
      {
        transactionBlock: txb,
        options: {
          showEffects: true,
          showObjectChanges: true,
        },
      },
      {
        onSuccess: (tx) => {
          client
            .waitForTransactionBlock({ digest: tx.digest })
            .then(() => {
              if (onCreate) onCreate();
            })
            .catch((error) => {
              console.log(error);
            })
            .finally(() => {
              setIsCreating(false);
            });
        },
        onError: (error) => {
          console.log(error);

          setIsCreating(false);
        },
      }
    );
  };

  if (!currentAccount || currentAccount.chains[0] !== SUI_DEVNET_CHAIN) return;

  return (
    <>
      <Button onPress={createGame} color="primary" isLoading={isCreating} className={classname}>
        Create Game
      </Button>
    </>
  );
}
