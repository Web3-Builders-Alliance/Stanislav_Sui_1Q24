import { AccountContext } from "@/context/account-context";
import { useNetworkVariable } from "@/utils/networkConfig";
import { Game, getAccountFields, getGameFields } from "@/utils/objects";
import {
  useCurrentAccount,
  useSignAndExecuteTransactionBlock,
  useSuiClient,
  useSuiClientQuery,
} from "@mysten/dapp-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { MIST_PER_SUI, normalizeSuiAddress } from "@mysten/sui.js/utils";
import { Button, Card, CardBody, Link } from "@nextui-org/react";

import { useContext, useEffect, useState } from "react";

export default function GameCard({ id }: { id: string }) {
  const [game, setGame] = useState<Game>();
  const [playerName1, setPlayerName1] = useState<string>();
  const [playerName2, setPlayerName2] = useState<string>();

  const currentAccount = useCurrentAccount();
  const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
  const suigamesPackageId = useNetworkVariable("suigamesPackageId");
  const gamesPackId = useNetworkVariable("gamespackId");
  const hexgameType = useNetworkVariable("hexgameType");

  const { accountId: currentAccountId } = useContext(AccountContext);

  const client = useSuiClient();

  const { data, isPending, error, refetch } = useSuiClientQuery("getObject", {
    id,
    options: {
      showContent: true,
    },
  });

  useEffect(() => {
    if (!data?.data) {
      return;
    }
    setGame(getGameFields(data.data)!);
  }, [data]);

  useEffect(() => {
    (async () => {
      if (!game) {
        return;
      }

      let player1Account = await client.getObject({
        id: game.player1,
        options: {
          showContent: true,
        },
      });

      if (player1Account.data) {
        setPlayerName1(getAccountFields(player1Account.data)?.name);
      }

      let player2_id = game.player2;
      if (player2_id !== normalizeSuiAddress("0")) {
        let player2Account = await client.getObject({
          id: player2_id,
          options: {
            showContent: true,
          },
        });

        if (player2Account.data) {
          setPlayerName2(getAccountFields(player2Account.data)?.name);
        }
      }
    })();
  }, [game, client]);

  const cancelGame = async () => {
    if (!currentAccount) {
      return;
    }
    const txb = new TransactionBlock();

    let [coin, state] = txb.moveCall({
      arguments: [
        txb.object(id),
        txb.object(gamesPackId),
        txb.object(currentAccountId),
      ],
      target: `${suigamesPackageId}::game::cancel_game`,
      typeArguments: [gameType, stateType],
    });

    txb.transferObjects([coin], currentAccount.address);

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
              refetch();
            })
            .catch((error) => {
              console.log(error);
            })
            .finally(() => {});
        },
        onError: (error) => {
          console.log(error);
        },
      }
    );
  };

  const joinGame = async () => {
    if (!currentAccount) {
      return;
    }
    const txb = new TransactionBlock();

    let [coin] = txb.splitCoins(txb.gas, [game!.bet]);

    txb.moveCall({
      arguments: [txb.object(id), txb.object(currentAccountId), coin],
      target: `${suigamesPackageId}::game::join_game`,
      typeArguments: [gameType, stateType],
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
              refetch();
            })
            .catch((error) => {
              console.log(error);
            })
            .finally(() => {});
        },
        onError: (error) => {
          console.log(error);
        },
      }
    );
  };

  const withdraw = async () => {
    if (!currentAccount) {
      return;
    }
    const txb = new TransactionBlock();

    let [coin] = txb.moveCall({
      arguments: [txb.object(id), txb.object(currentAccountId)],
      target: `${suigamesPackageId}::game::withdraw`,
      typeArguments: [gameType, stateType],
    });

    txb.transferObjects([coin], currentAccount.address);

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
              refetch();
            })
            .catch((error) => {
              console.log(error);
            })
            .finally(() => {});
        },
        onError: (error) => {
          console.log(error);
        },
      }
    );
  };

  const deleteGame = async () => {
    if (!currentAccount) {
      return;
    }
    const txb = new TransactionBlock();

    let [state] = txb.moveCall({
      arguments: [
        txb.object(id),
        txb.object(gamesPackId),
        txb.object(currentAccountId),
      ],
      target: `${suigamesPackageId}::game::delete_game`,
      typeArguments: [gameType, stateType],
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
              refetch();
            })
            .catch((error) => {
              console.log(error);
            })
            .finally(() => {});
        },
        onError: (error) => {
          console.log(error);
        },
      }
    );
  };

  if (isPending) return <div>Loading...</div>;
  if (error) return <div>Error</div>;

  if (!data.data) return;
  // @ts-ignore
  const matches = /([^<]+)<([^,]+),\s([^>]+)>/.exec(data.data.content.type)!;

  const gameType = matches[2];
  const stateType = matches[3];

  return (
    <Card>
      <CardBody>
        {gameType === hexgameType && (
          <h1 className="text-center">Hex Board Game</h1>
        )}
        <p>
          {playerName1 ? playerName1 : "???"} vs{" "}
          {playerName2 ? playerName2 : "???"}
        </p>
        <p>Bet: {game?.bet! / Number(MIST_PER_SUI)} Sui</p>
        <p>Started: {game?.is_started ? "yes" : "no"}</p>
        <p>Ended: {game?.winner_index !== 0 ? "yes" : "no"}</p>
        {currentAccountId &&
          !game?.is_started &&
          (game?.player1 === currentAccountId ? (
            <Button onPress={cancelGame}>Cancel game</Button>
          ) : (
            (game?.player2 === currentAccountId ||
              game?.player2 === normalizeSuiAddress("0")) && (
              <Button onPress={joinGame}>Join game</Button>
            )
          ))}
        {game?.winner_index !== 0 && (
          <>
            <p>
              Winner: {game?.winner_index === 1 ? playerName1 : playerName2}
            </p>
            {((game?.winner_index === 1 &&
              game?.player1 === currentAccountId) ||
              (game?.winner_index === 2 &&
                game?.player2 === currentAccountId)) &&
              (game?.bet > 0 ? (
                <Button onPress={withdraw}>Withdraw</Button>
              ) : (
                <Button onPress={deleteGame}>Delete game</Button>
              ))}
          </>
        )}
        <Link href={`/${id}`}> Open game </Link>
      </CardBody>
    </Card>
  );
}
