export default function Hex({
  center_x,
  center_y,
  size,
  color,
  row,
  col,
  onClick,
}: {
  center_x: number;
  center_y: number;
  size: number;
  color: string;
  row: number;
  col: number;
  onClick: (row: number, col: number) => void;
}) {
  const x = center_x;
  const y = center_y;
  const points = [
    {
      x: x + Math.cos(Math.PI / 6) * size,
      y: y + Math.sin(Math.PI / 6) * size,
    },
    {
      x: x + Math.cos(Math.PI / 2) * size,
      y: y + Math.sin(Math.PI / 2) * size,
    },
    {
      x: x + Math.cos((5 / 6) * Math.PI) * size,
      y: y + Math.sin((5 / 6) * Math.PI) * size,
    },
    {
      x: x + Math.cos((7 / 6) * Math.PI) * size,
      y: y + Math.sin((7 / 6) * Math.PI) * size,
    },
    {
      x: x + Math.cos((9 / 6) * Math.PI) * size,
      y: y + Math.sin((9 / 6) * Math.PI) * size,
    },
    {
      x: x + Math.cos((11 / 6) * Math.PI) * size,
      y: y + Math.sin((11 / 6) * Math.PI) * size,
    },
  ];

  return (
    <polygon
      points={points.map((p) => `${p.x},${p.y}`).join(" ")}
      stroke="black"
      fill={color}
      onClick={() => onClick(row, col)}
    />
  );
}
