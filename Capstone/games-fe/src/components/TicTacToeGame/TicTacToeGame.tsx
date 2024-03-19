import React, { useContext, useEffect, useState } from "react";
import TicTacToeField from "./TicTacToeField";
import {
  useCurrentAccount,
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { AccountContext } from "@/context/account-context";
import { useNetworkVariable } from "@/utils/networkConfig";
import { Game, getAccountFields, getBoardFromState } from "@/utils/objects";
import { normalizeSuiAddress } from "@mysten/sui.js/utils";
import { Button } from "@nextui-org/react";
import { TransactionBlock } from "@mysten/sui.js/transactions";

export default function TicTacToeGame({
  gameId,
  game,
  refetch,
}: {
  gameId: string;
  game: Game;
  refetch: () => void;
}) {
  const client = useSuiClient();
  const [playerName1, setPlayerName1] = useState("");
  const [playerName2, setPlayerName2] = useState("");

  const { accountId: currentAccountId } = useContext(AccountContext);

  const currentAccount = useCurrentAccount();
  const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
  const tictactoePackageId = useNetworkVariable("tictactoePackageId");
  const suigamesPackageId = useNetworkVariable("suigamesPackageId");
  const gamespackId = useNetworkVariable("gamespackId");
  const tictactoeType = useNetworkVariable("tictactoeType");
  const tictactoeBoardType = useNetworkVariable("tictactoeBoardType");

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
  const [pathDirection, setPathDirection] = useState<{
    path: { row: number; col: number }[];
    direction: number;
  } | null>(null);

  const isYourTurn =
    game.is_started &&
    (game.is_first_player_turn
      ? currentAccountId === game.player1
      : currentAccountId === game.player2);

  const isPlayer =
    game.player1 === currentAccountId || game.player2 === currentAccountId;

  // const curPlayerNum = 2;
  const curPlayerNum = game.is_first_player_turn ? 1 : 2;

  const curAccountPlayerNum = currentAccountId === game.player1 ? 1 : 2;

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
  //   [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  //   [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  //   [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  //   [1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
  //   [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
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

  const findPath = (
    field: number[][],
    move: { row: number; col: number },
    playerNum: number
  ): { path: { row: number; col: number }[]; direction: number } | null => {
    const range = (start: number, end: number) =>
      Array.from({ length: end - start }, (v, k) => k + start);

    // col
    let count = 0;
    for (let i = 0; i < field.length; i++) {
      if (field[i][move.col] === playerNum) {
        count++;
        if (count === 5) {
          return {
            path: range(i - 4, i + 1).map((row) => {
              return { row, col: move.col };
            }),
            direction: 0,
          };
        }
      } else {
        count = 0;
      }
    }

    // row
    count = 0;
    for (let i = 0; i < field.length; i++) {
      if (field[move.row][i] === playerNum) {
        count++;
        if (count === 5) {
          return {
            path: range(i - 4, i + 1).map((col) => {
              return { row: move.row, col };
            }),
            direction: 1,
          };
        }
      } else {
        count = 0;
      }
    }

    // diag left->right
    count = 0;
    for (let i = 0; i < field.length; i++) {
      let col_tmp = move.col - (move.row - i);
      if (col_tmp < 0 || col_tmp >= 15) {
        continue;
      }
      // console.log(row, col_tmp);
      if (field[i][col_tmp] === playerNum) {
        count++;
        if (count === 5) {
          return {
            path: range(i - 4, i + 1).map((row) => {
              return { row, col: move.col - (move.row - row) };
            }),
            direction: 2,
          };
        }
      } else {
        count = 0;
      }
    }

    // diag right->left
    count = 0;
    for (let i = 0; i < field.length; i++) {
      let col_tmp = move.col + (move.row - i);
      if (col_tmp < 0 || col_tmp >= 15) {
        continue;
      }
      if (field[i][col_tmp] === playerNum) {
        count++;
        if (count === 5) {
          return {
            path: range(i - 4, i + 1).map((row) => {
              return { row, col: move.col + (move.row - row) };
            }),
            direction: 3,
          };
        }
      } else {
        count = 0;
      }
    }

    return null;
  };

  const handleClick = (row: number, col: number) => {
    if (!isYourTurn || game.is_gameover) {
      return;
    }

    if (field[row][col] === 0) {
      setCurMove({ row, col });
    }
    let field_copy = field.map((row) => [...row]);
    field_copy[row][col] = curPlayerNum;
    let pathDirection = findPath(field_copy, { row, col }, curPlayerNum);
    // console.log(pathDirection?.path, pathDirection?.direction);

    setPathDirection(pathDirection);
  };

  const move = async (win: boolean) => {
    if (!currentAccount) {
      return;
    }
    const txb = new TransactionBlock();

    txb.moveCall({
      arguments: [
        txb.object(gameId),
        txb.object(gamespackId),
        txb.object(currentAccountId),
        txb.pure(curMove.row! * board.size + curMove.col!),
      ],
      target: `${tictactoePackageId}::main::make_move`,
    });

    if (win) {
      const path_raw = pathDirection!.path.map(
        ({ row, col }) => row * board.size + col
      );
      txb.moveCall({
        arguments: [
          txb.object(gameId),
          txb.object(gamespackId),
          txb.object(currentAccountId),
          txb.pure(path_raw),
          txb.pure(pathDirection!.direction),
        ],
        target: `${tictactoePackageId}::main::declare_win`,
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

  const draw = async () => {
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
      target: `${suigamesPackageId}::game::suggest_draw`,
      typeArguments: [tictactoeType, tictactoeBoardType],
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
      target: `${tictactoePackageId}::main::give_up`,
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
      <h1 className="mb-4 text-center">Tic Tac Toe 5 in a Row</h1>
      <p className="mb-4 text-center">
        {playerName1 ? playerName1 : "???"} (crosses) vs{" "}
        {playerName2 ? playerName2 : "???"} (noughts)
      </p>
      {!game.is_started ? (
        <p className="mb-4 text-center">Game has not started</p>
      ) : !game.is_gameover ? (
        <p className="mb-4  text-center">
          Current turn:{" "}
          {curPlayerNum == 1
            ? playerName1 + " (crosses)"
            : playerName2 + " (noughts)"}
        </p>
      ) : (
        <p className="mb-4 text-center">
          The game is over.{" "}
          {game.winner_index == 0
            ? "Draw"
            : (game.winner_index == 1 ? playerName1 : playerName2) + " won"}
        </p>
      )}
      <div className="flex justify-center">
        <TicTacToeField
          field={field}
          curMove={curMove}
          curPlayerNum={curPlayerNum}
          onClick={handleClick}
        />
      </div>
      <div className="flex justify-center mt-3">
        {pathDirection ? (
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
            isDisabled={
              !isYourTurn || game.is_gameover || curMove.row == undefined
            }
            onPress={() => move(false)}
          >
            Move
          </Button>
        )}
        <Button
          color="warning"
          isDisabled={
            (game.suggested_draw_mask & 1 && curAccountPlayerNum == 1) ||
            (game.suggested_draw_mask & 2 && curAccountPlayerNum == 2) ||
            !game.is_started ||
            !isPlayer ||
            game.is_gameover
          }
          className="ml-2"
          onPress={draw}
        >
          Draw
        </Button>

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
