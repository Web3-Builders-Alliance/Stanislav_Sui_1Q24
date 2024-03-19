import React, { useState } from "react";
import TicTacToeField from "./TicTacToeField";

export default function TicTacToeGame() {
  // const [field, setField] = useState<number[][]>(
  //   new Array(15).fill(Array(15).fill(0))
  // );
  const field = [
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
    [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ];

  const [curMove, setCurMove] = useState<{ row?: number; col?: number }>({});

  const curPlayerNum = 1;

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
    // console.log(row, col);

    // if (!isYourTurn || game.is_gameover) {
    //   return;
    // }
    // console.log(row, col);

    if (field[row][col] === 0) {
      setCurMove({ row, col });
    }
    if (field[row][col] === 0) {
      setCurMove({ row, col });
    }
    let field_copy = field.map((row) => [...row]);
    field_copy[row][col] = curPlayerNum;

    let pathDirection = findPath(field_copy, { row, col }, curPlayerNum);
    console.log(pathDirection?.path, pathDirection?.direction);

    // setPath(findPath(grid, board.size, curPlayerNum));
  };

  return (
    <TicTacToeField
      field={field}
      curMove={curMove}
      curPlayerNum={curPlayerNum}
      onClick={handleClick}
    />
  );
}
