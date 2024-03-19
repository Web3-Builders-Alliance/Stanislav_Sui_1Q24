import "./tictactoe.css";

export default function TicTacToeField({
  field,
  curMove,
  curPlayerNum,
  onClick,
}: {
  field: number[][];
  curMove: { row?: number; col?: number };
  curPlayerNum: number;
  onClick: (row: number, col: number) => void;
}) {
  const renderSquare = (row: number, col: number) => {
    let value;
    if (row == curMove.row && col == curMove.col) {
      value = curPlayerNum == 2 ? "O" : "X";
    } else {
      if (field[row][col] == 1) {
        value = "X";
      } else if (field[row][col] == 2) {
        value = "O";
      } else {
        value = null;
      }
    }

    return (
      <button key={col} className="square" onClick={() => onClick(row, col)}>
        {value}
      </button>
    );
  };

  return (
    <>
      {field.map((row, i) => (
        <div key={i} className="field-row">
          {row.map((_, j) => renderSquare(i, j))}
        </div>
      ))}
    </>
  );
}
