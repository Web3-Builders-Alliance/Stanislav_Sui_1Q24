import {
  Game,
  getAccountFields,
  getGameFields,
} from "@/utils/objects";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { Card, CardBody } from "@nextui-org/react";

import { useEffect, useState } from "react";

export default function GameCard({ id }: { id: string }) {
  const [game, setGame] = useState<Game>();
  const [playerName1, setPlayerName1] = useState<string>();
  const [playerName2, setPlayerName2] = useState<string>();

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
      console.log(player1Account);
      if (player1Account.data) {
        setPlayerName1(getAccountFields(player1Account.data)?.name);
      }

      let player2_id = game.player2;
      if (
        player2_id !==
        "0x0000000000000000000000000000000000000000000000000000000000000000"
      ) {
        let player2Account = await client.getObject({
          id: player2_id,
          options: {
            showContent: true,
          },
        });

        console.log(player2Account);
        if (player2Account.data) {
          setPlayerName2(getAccountFields(player2Account.data)?.name);
        }
      }
    })();
  }, [game, client]);

  if (isPending) return <div>Loading...</div>;
  if (error) return <div>Error</div>;

  if (!data.data) return;

  return (
    <Card>
      <CardBody>
        {/* <p>{JSON.stringify(getGameFields(data.data)?.game_state)}</p> */}
        {/* <p>
          {JSON.stringify(
            getBoardFromState(getGameFields(data.data)?.game_state!)
          )}
        </p> */}
        <p>
          {playerName1} vs {playerName2 ? playerName2 : "???"}
        </p>
        <p>Bet: {game?.bet}</p>
        <p>Started: {game?.is_started ? "yes" : "no"}</p>
      </CardBody>
    </Card>
  );
}
