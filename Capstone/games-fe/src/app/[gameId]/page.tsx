"use client";
import HexGame from "@/components/HexGame/HexGame";
import TicTacToeGame from "@/components/TicTacToeGame/TicTacToeGame";
import { useNetworkVariable } from "@/utils/networkConfig";
import { getGameFields } from "@/utils/objects";
import { useSuiClientQuery } from "@mysten/dapp-kit";

export default function Game({ params }: { params: { gameId: string } }) {
  const suigamesPackageId = useNetworkVariable("suigamesPackageId");
  const hexgameType = useNetworkVariable("hexgameType");
  const tictactoeType = useNetworkVariable("tictactoeType");

  const { data, isPending, error, refetch } = useSuiClientQuery("getObject", {
    id: params.gameId,
    options: {
      showContent: true,
    },
  });

  if (isPending) return <p>Loading...</p>;
  if (error) return <p>Error</p>;

  if (
    !data ||
    !data.data ||
    !data.data.content ||
    data.data.content.dataType !== "moveObject"
  ) {
    return <p>Wrong id</p>;
  }

  const matches = /([^<]+)<([^,]+),\s([^>]+)>/.exec(data.data.content.type);
  if (!matches) {
    return <p>Not a game</p>;
  }

  if (matches[1] !== `${suigamesPackageId}::game::Game`) {
    return <p>Unknown game</p>;
  }

  const game = getGameFields(data.data)!;

  if (matches[2] === hexgameType) {
    return <HexGame gameId={params.gameId} game={game} refetch={refetch} />;
  } else if (matches[2] === tictactoeType) {
    return (
      <TicTacToeGame gameId={params.gameId} game={game} refetch={refetch} />
    );
  } else {
    return <p>Unknown game</p>;
  }
}
