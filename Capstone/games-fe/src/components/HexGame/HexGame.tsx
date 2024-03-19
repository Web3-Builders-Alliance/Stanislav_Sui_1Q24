import { Game, getAccountFields, getBoardFromState } from "@/utils/objects";
import HexField from "./HexField";
import { useContext, useEffect, useState } from "react";
import { AccountContext } from "@/context/account-context";
import { Button } from "@nextui-org/react";
import {
  useCurrentAccount,
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { normalizeSuiAddress } from "@mysten/sui.js/utils";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { useNetworkVariable } from "@/utils/networkConfig";

export default function HexGame({
  gameId,
  game,
  refetch,
}: {
  gameId: string;
  game: Game;
  refetch: () => void;
}) {
  const player1Color = "#54a7c5";
  const player2Color = "#b823c4";

  const client = useSuiClient();
  const [playerName1, setPlayerName1] = useState("");
  const [playerName2, setPlayerName2] = useState("");

  const { accountId: currentAccountId } = useContext(AccountContext);

  const currentAccount = useCurrentAccount();
  const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
  const hexgamePackageId = useNetworkVariable("hexgamePackageId");
  const suigamesPackageId = useNetworkVariable("suigamesPackageId");
  const gamespackId = useNetworkVariable("gamespackId");
  const hexgameType = useNetworkVariable("hexgameType");
  const hexgameBoardType = useNetworkVariable("hexgameBoardType");

  useEffect(() => {
    (async () => {
      if (!client) {
        return;
      }
      setCurMove({});
      let player1Account = await client.getObject({
        id: game.player1,
        options: {
          showContent: true,
        },
      });

      if (player1Account.data) {
        setPlayerName1(getAccountFields(player1Account.data)!.name);
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
          setPlayerName2(getAccountFields(player2Account.data)!.name);
        }
      }
    })();
  }, [client, game]);

  const [curMove, setCurMove] = useState<{ row?: number; col?: number }>({});
  const [path, setPath] = useState<{ row: number; col: number }[] | null>(null);

  const isYourTurn =
    game.is_started &&
    (game.is_first_player_turn
      ? currentAccountId === game.player1
      : currentAccountId === game.player2);

  const isPlayer =
    game.player1 === currentAccountId || game.player2 === currentAccountId;

  // const curPlayerNum = 2;
  const curPlayerNum = game.is_first_player_turn ? 1 : 2;

  const constructMatrixField = (field: number[], size: number) => {
    let matrix = [];

    for (let i = 0; i < size; i++) {
      let row = [];
      for (let j = 0; j < size; j++) {
        row.push(field[i * size + j]);
      }
      matrix.push(row);
    }
    return matrix;
  };

  const board = getBoardFromState(game.game_state);
  const field = constructMatrixField(board.field, board.size);

  // const field = [
  //   [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 1, 1, 0, 0, 2, 2, 2, 0, 0],
  //   [0, 0, 1, 1, 0, 2, 0, 0, 2, 0, 0],
  //   [2, 2, 0, 1, 2, 0, 0, 0, 2, 0, 0],
  //   [0, 2, 0, 2, 1, 1, 1, 0, 2, 2, 0],
  //   [0, 2, 2, 0, 0, 0, 1, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
  // ];

  useEffect(() => {
    const interval = setInterval(() => {
      if (!isYourTurn) {
        refetch();
      }
    }, 2000);
    return () => clearInterval(interval);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const findPath = (grid: number[][], size: number, playerNum: number) => {
    const rows = size;
    const cols = size;
    const visited = Array(rows)
      .fill(0)
      .map(() => Array(cols).fill(false));
    let path: { row: number; col: number }[] = [];

    const directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
      [-1, 1],
      [1, -1],
    ];

    function bfs(row: number, col: number) {
      let queue = [{ row, col, path }];

      while (queue.length > 0) {
        let { row, col, path } = queue.shift()!;

        if (
          row < 0 ||
          row >= rows ||
          col < 0 ||
          col >= cols ||
          visited[row][col] ||
          grid[row][col] != playerNum
        ) {
          continue;
        }

        visited[row][col] = true;
        path.push({ row, col });

        if (playerNum == 1) {
          if (row === rows - 1) {
            return path;
          }
        } else {
          if (col === cols - 1) {
            return path;
          }
        }

        for (let [drow, dcol] of directions) {
          let pathCopy = path.slice(); // create a copy of path
          queue.push({ row: row + drow, col: col + dcol, path: pathCopy });
        }
      }

      return null;
    }

    if (playerNum == 1) {
      for (let col = 0; col < cols; col++) {
        path = []; // Reset the path for each starting point
        let result = bfs(0, col);
        if (result) {
          return result;
        }
      }
    } else {
      for (let row = 0; row < rows; row++) {
        path = []; // Reset the path for each starting point
        let result = bfs(row, 0);
        if (result) {
          return result;
        }
      }
    }
    return null; // If no path was found after all starting points were attempted
  };

  const handleClick = (row: number, col: number) => {
    // console.log(row, col);

    if (!isYourTurn || game.is_gameover) {
      return;
    }

    if (field[row][col] === 0) {
      setCurMove({ row, col });
    }
    let field_copy = field.map((row) => [...row]);
    field_copy[row][col] = curPlayerNum;
    let path = findPath(field_copy, board.size, curPlayerNum);

    setPath(path);
  };

  const move = async (win: boolean) => {
    if (!currentAccount) {
      return;
    }
    const txb = new TransactionBlock();

    txb.moveCall({
      arguments: [
        txb.object(gameId),
        txb.object(currentAccountId),
        txb.pure(curMove.row! * board.size + curMove.col!),
      ],
      target: `${hexgamePackageId}::main::make_move`,
    });

    if (win) {
      const path_raw = path!.map(({ row, col }) => row * board.size + col);
      txb.moveCall({
        arguments: [
          txb.object(gameId),
          txb.object(gamespackId),
          txb.object(currentAccountId),
          txb.pure(path_raw),
        ],
        target: `${hexgamePackageId}::main::declare_win`,
      });
    }

    signAndExecute(
      {
        transactionBlock: txb,
        options: {
          showEffects: true,
          showObjectChanges: true,
        },
        requestType: "WaitForLocalExecution",
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
            });
        },
        onError: (error) => {
          console.log(error);
        },
      }
    );
  };

  const swapSides = async () => {
    if (!currentAccount) {
      return;
    }
    const txb = new TransactionBlock();

    txb.moveCall({
      arguments: [txb.object(gameId), txb.object(currentAccountId)],
      target: `${suigamesPackageId}::game::swap_sides`,
      typeArguments: [hexgameType, hexgameBoardType],
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
            });
        },
        onError: (error) => {
          console.log(error);
        },
      }
    );
  };

  const giveUp = async () => {
    if (!currentAccount) {
      return;
    }
    const txb = new TransactionBlock();

    txb.moveCall({
      arguments: [
        txb.object(gameId),
        txb.object(gamespackId),
        txb.object(currentAccountId),
      ],
      target: `${hexgamePackageId}::main::give_up`,
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
            });
        },
        onError: (error) => {
          console.log(error);
        },
      }
    );
  };

  return (
    <main>
      <h1 className="mb-4 mr-20 text-center">Hex Board Game</h1>
      <p className="mb-4 mr-20 text-center">
        <span style={{ color: player1Color }}>
          {playerName1 ? playerName1 : "???"}
        </span>{" "}
        vs{" "}
        <span style={{ color: player2Color }}>
          {playerName2 ? playerName2 : "???"}
        </span>
      </p>
      {!game.is_started ? (
        <p className="mb-4 mr-20 text-center">Game has not started</p>
      ) : !game.is_gameover ? (
        <p
          className="mb-4 mr-20 text-center"
          style={{ color: curPlayerNum == 1 ? player1Color : player2Color }}
        >
          Current turn: {curPlayerNum == 1 ? playerName1 : playerName2}
        </p>
      ) : (
        <p
          className="mb-4 mr-20 text-center"
          style={{
            color: game.winner_index == 1 ? player1Color : player2Color,
          }}
        >
          The game is over. {game.winner_index == 1 ? playerName1 : playerName2}{" "}
          won
        </p>
      )}
      <div className="flex justify-center">
        <HexField
          field={field}
          rows={board.size}
          cols={board.size}
          curMove={curMove}
          curPlayerNum={curPlayerNum}
          player1Color={player1Color}
          player2Color={player2Color}
          onClick={handleClick}
        />
      </div>
      <div className="flex justify-center mt-3">
        {path ? (
          <Button
            color="primary"
            isDisabled={!isYourTurn || game.is_gameover}
            onPress={() => move(true)}
          >
            Win
          </Button>
        ) : (
          <Button
            color="primary"
            isDisabled={!isYourTurn || game.is_gameover || curMove.row == undefined}
            onPress={() => move(false)}
          >
            Move
          </Button>
        )}
        {isYourTurn && !game.is_first_player_turn && game.turn_number == 1 && (
          <Button color="warning" className="ml-2" onPress={swapSides}>
            Swap Sides
          </Button>
        )}
        <Button
          color="danger"
          isDisabled={!game.is_started || !isPlayer || game.is_gameover}
          className="ml-2"
          onPress={giveUp}
        >
          Give Up
        </Button>
      </div>
    </main>
  );
}
