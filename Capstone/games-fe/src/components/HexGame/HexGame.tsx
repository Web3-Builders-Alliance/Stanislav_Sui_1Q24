import { Game } from "@/utils/objects";
import HexField from "./HexField";
import { useContext, useState } from "react";
import { AccountContext } from "@/context/account-context";

export default function HexGame({
  game,
  refetch,
}: {
  game: Game;
  refetch: () => void;
}) {
  const player1Color = "red";
  const player2Color = "blue";

  const { accountId: currentAccountId } = useContext(AccountContext);

  const [curMove, setCurMove] = useState({});

  const isYourTurn = game?.is_first_player_turn
    ? currentAccountId === game.player1
    : currentAccountId === game.player2;
  const isGameOver = game.winner_index !== 0;

  const curPlayerNum = game.is_first_player_turn ? 1 : 2;
/*
  const findPath = (grid: number[][], size: number, playerNum: number) => {
    const rows = size;
    const cols = size;
    const visited = Array(rows)
      .fill(0)
      .map(() => Array(cols).fill(false));
    let path: number[] = [];

    const directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
      [-1, 1],
      [1, -1],
    ];

    function bfs(x: number, y: number) {
      let queue = [{x, y, path}];

      while (queue.length > 0) {
        let {x, y, path} = queue.shift()!;

        if (
          x < 0 ||
          x >= rows ||
          y < 0 ||
          y >= cols ||
          visited[x][y] ||
          grid[x][y] != playerNum
        ) {
          continue;
        }

        visited[x][y] = true;
        path.push([x, y]);

        if (playerNum == 1) {
          if (x === rows - 1) {
            return path;
          }
        } else {
          if (y === rows - 1) {
            return path;
          }
        }

        for (let [dx, dy] of directions) {
          let pathCopy = path.slice(); // create a copy of path
          queue.push([x + dx, y + dy, pathCopy]);
        }
      }

      return null;
    }

    if (playerNum == 1) {
      for (let y = 0; y < cols; y++) {
        path = []; // Reset the path for each starting point
        let result = bfs(0, y);
        if (result) {
          return result;
        }
      }
    } else {
      for (let x = 0; x < rows; x++) {
        path = []; // Reset the path for each starting point
        let result = bfs(x, 0);
        if (result) {
          return result;
        }
      }
    }
    return null; // If no path was found after all starting points were attempted
  };
*/
  const handleClick = (row: number, col: number) => {
    // console.log(row, col);

    // if (!isYourTurn || isGameOver) {
    //   return;
    // }

    if (field[row][col] === 0) {
      setCurMove({ row, col });
    }
  };

  const field = [
    [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 1, 0, 0, 2, 2, 2, 0, 0],
    [0, 0, 1, 1, 0, 2, 0, 0, 2, 0, 0],
    [2, 2, 0, 1, 2, 0, 0, 0, 2, 0, 2],
    [0, 2, 0, 2, 1, 1, 1, 0, 2, 2, 0],
    [0, 2, 2, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
  ];

  return (
    <main>
      <h1>Hex Game</h1>

      <HexField
        field={field}
        rows={11}
        cols={11}
        curMove={curMove}
        curPlayerNum={curPlayerNum}
        player1Color={player1Color}
        player2Color={player2Color}
        onClick={handleClick}
      />
    </main>
  );
}
