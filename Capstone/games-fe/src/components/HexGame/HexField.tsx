import Hex from "./Hex";

export default function HexField({
  field,
  rows,
  cols,
  hexSize = 20,
  curMove,
  curPlayerNum,
  player1Color,
  player2Color,
  onClick,
}: {
  field: number[][];
  rows: number;
  cols: number;
  hexSize?: number;
  curMove: { row?: number; col?: number };
  curPlayerNum: number;
  player1Color: string;
  player2Color: string;
  onClick: (row: number, col: number) => void;
}) {
  const width = Math.sqrt(3) * hexSize;
  const height = (2 - Math.sin(Math.PI / 6)) * hexSize;

  const hexes = [];

  hexes.push(
    <polygon
      key={0}
      points={`${width / 2},0 ${width * (cols - 1) + width + width / 2},0 ${
        width * (cols - 1) + width + width / 2
      },${hexSize} ${width / 2},${hexSize}`}
      stroke={player1Color}
      fill={player1Color}
    />
  );

  hexes.push(
    <polygon
      key={1}
      points={`${width * (cols - 1) + (width / 2) * rows + width},${
        height * (rows + 1)
      } ${(width / 2) * rows},${height * (rows + 1)} ${(width / 2) * rows},${
        height * (rows + 1) - hexSize
      } ${width * (cols - 1) + (width / 2) * rows + width},${
        height * (rows + 1) - hexSize
      }`}
      stroke={player1Color}
      fill={player1Color}
    />
  );

  hexes.push(
    <polygon
      key={2}
      points={`${0},${height} ${width},${height} ${
        (width / 2) * rows + width / 2
      },${height * rows} ${(width / 2) * rows - width / 2},${height * rows}`}
      stroke={player2Color}
      fill={player2Color}
    />
  );

  hexes.push(
    <polygon
      key={3}
      points={`${width * cols},${height} ${width * (cols + 1)},${height} ${
        width * cols + (width / 2) * rows + width / 2
      },${height * rows} ${
        width * (cols - 1) + (width / 2) * rows + width / 2
      },${height * rows}`}
      stroke={player2Color}
      fill={player2Color}
    />
  );

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      const x = width * col + (width / 2) * (row + 1) + width / 2;
      const y = height * row + height;

      let color;
      if (row == curMove.row && col == curMove.col) {
        color = curPlayerNum == 2 ? player2Color : player1Color;
      } else {
        if (field[row][col] == 1) {
          color = player1Color;
        } else if (field[row][col] == 2) {
          color = player2Color;
        } else {
          color = "white";
        }
      }
      hexes.push(
        <Hex
          key={row * cols + col + 4}
          center_x={x}
          center_y={y}
          size={hexSize}
          color={color}
          row={row}
          col={col}
          onClick={onClick}
        />
      );
    }
  }

  return (
    <svg
      style={{
        width: width * cols + (width / 2) * rows + width / 2,
        height: height * (rows + 1),
      }}
    >
      {hexes}
    </svg>
  );
}
