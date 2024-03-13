import { useNetworkVariable } from "@/utils/networkConfig";
import { getGamesFromGamepack } from "@/utils/objects";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";

import { useEffect, useState } from "react";
import GameCard from "./GameCard";

export default function GamesList() {
  const gamesPackId = useNetworkVariable("gamespackId");
  const hamegameType = useNetworkVariable("hexgameType");

  const [gameIds, setGameIds] = useState<string[]>([]);

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
        parentId: getGamesFromGamepack(data.data, hamegameType),
      });

      setGameIds(fields.data.map((game: any) => game.name.value));
    })();
  }, [data, hamegameType, client]);

  if (isPending) return <div>Loading...</div>;
  if (error) return <div>Error</div>;

  if (!data.data) return;

  // console.log(games);

  return (
    <div className="grid md:grid-cols-3 gap-4">
      {gameIds.map((gameId) => (
        <GameCard key={gameId} id={gameId} />
      ))}
    </div>
  );
  // return <>{gameIds.map((gameId) => gameId)}</>;
}
