import { useNetworkVariable } from "@/utils/networkConfig";
import { getGamesFromGamepack } from "@/utils/objects";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";

import { useEffect, useState } from "react";
import GameCard from "./GameCard";

export default function GamesList() {
  const gamesPackId = useNetworkVariable("gamespackId");
  const hexgameType = useNetworkVariable("hexgameType");
  const tictactoeType = useNetworkVariable("tictactoeType");

  const [hexGameIds, setHexGameIds] = useState<string[]>([]);
  const [tictactoeIds, setTictactoeIds] = useState<string[]>([]);

  const client = useSuiClient();

  const { data, isPending, error, refetch } = useSuiClientQuery("getObject", {
    id: gamesPackId,
    options: {
      showContent: true,
    },
  });

  useEffect(() => {
    (async () => {
      if (!data?.data) {
        return;
      }

      let fields = await client.getDynamicFields({
        parentId: getGamesFromGamepack(data.data, hexgameType),
      });

      setHexGameIds(fields.data.map((game: any) => game.name.value));

      fields = await client.getDynamicFields({
        parentId: getGamesFromGamepack(data.data, tictactoeType),
      });

      setTictactoeIds(fields.data.map((game: any) => game.name.value));
    })();
  }, [data, hexgameType, tictactoeType, client]);

  if (isPending) return <div>Loading...</div>;
  if (error) return <div>Error</div>;

  if (!data.data) return;

  return (
    <>
      {hexGameIds.length > 0 && <h1>Hex Board Games List</h1>}
      <div className="grid md:grid-cols-3 gap-4">
        {hexGameIds.map((gameId) => (
          <GameCard key={gameId} id={gameId} />
        ))}
      </div>
      {tictactoeIds.length > 0 && <h1>Tic Tac Toe 5 in Row Games List</h1>}
      <div className="grid md:grid-cols-3 gap-4">
        {tictactoeIds.map((gameId) => (
          <GameCard key={gameId} id={gameId} />
        ))}
      </div>
    </>
  );
}
