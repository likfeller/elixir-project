import { useMemo } from "react";
import type { Player } from "../types";

interface Props {
  player: Player;
  primaryColor: string;
  secondaryColor: string;
}

// viewBox geometry
const W = 380;
const H = 440;
const CX = 190; // avatar center x
const CY = 340; // avatar center y
const R = 52; // avatar radius
const ANCHOR_X = CX;
const ANCHOR_Y = CY - R - 4; // where traces leave the head

interface StatNode {
  label: string;
  value: string;
  x: number;
  y: number;
}

// Route a PCB-style trace from the head anchor up to a node:
// vertical riser -> 45° bevel -> horizontal run into the node.
function trace(x: number, y: number): string {
  const bevel = Math.min(16, Math.abs(x - ANCHOR_X));
  const sgn = x >= ANCHOR_X ? 1 : -1;
  if (bevel === 0) return `M ${ANCHOR_X},${ANCHOR_Y} L ${x},${y}`;
  return [
    `M ${ANCHOR_X},${ANCHOR_Y}`,
    `L ${ANCHOR_X},${y + bevel}`,
    `L ${ANCHOR_X + sgn * bevel},${y}`,
    `L ${x},${y}`,
  ].join(" ");
}

function initials(name: string): string {
  return name
    .split(" ")
    .map((p) => p[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();
}

export default function PlayerCircuit({ player, primaryColor, secondaryColor }: Props) {
  const nodes = useMemo<StatNode[]>(
    () => [
      { label: "GOALS", value: String(player.goals), x: 100, y: 92 },
      { label: "DRIBBLES", value: String(player.dribblesSuccess), x: 190, y: 50 },
      { label: "RATING", value: player.rating ? player.rating.toFixed(1) : "—", x: 300, y: 86 },
      { label: "ASSISTS", value: String(player.assists), x: 44, y: 180 },
      { label: "PASS %", value: `${player.passAccuracy}%`, x: 330, y: 176 },
      { label: "SHOTS", value: `${player.shotsOn}/${player.shotsTotal}`, x: 262, y: 240 },
    ],
    [player]
  );

  const gid = `grad-${player.id}`;
  const clip = `clip-${player.id}`;

  return (
    <svg className="player-circuit" viewBox={`0 0 ${W} ${H}`} role="img" aria-label={player.name}>
      <defs>
        <radialGradient id={gid} cx="50%" cy="35%" r="75%">
          <stop offset="0%" stopColor={primaryColor} stopOpacity="0.9" />
          <stop offset="100%" stopColor={secondaryColor} stopOpacity="0.95" />
        </radialGradient>
        <clipPath id={clip}>
          <circle cx={CX} cy={CY} r={R} />
        </clipPath>
        <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="2.4" result="b" />
          <feMerge>
            <feMergeNode in="b" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      {/* decorative background traces for the PCB feel */}
      <g className="deco" stroke={secondaryColor} fill={secondaryColor}>
        <path d="M 20,40 L 20,70 L 44,94 L 44,130" />
        <circle cx="20" cy="40" r="2.5" />
        <circle cx="44" cy="130" r="2.5" />
        <path d="M 360,40 L 360,76 L 336,100 L 336,132" />
        <circle cx="360" cy="40" r="2.5" />
        <circle cx="336" cy="132" r="2.5" />
        <path d="M 150,420 L 150,398 L 180,368" />
        <circle cx="150" cy="420" r="2.5" />
      </g>

      {/* traces from head to each stat node */}
      {nodes.map((n, i) => (
        <path
          key={`t-${i}`}
          className="trace"
          d={trace(n.x, n.y)}
          stroke={primaryColor}
          style={{ animationDelay: `${i * 0.35}s` }}
        />
      ))}

      {/* stat nodes */}
      {nodes.map((n, i) => {
        const side = n.x < 150 ? "end" : n.x > 230 ? "start" : "middle";
        const dx = side === "end" ? -12 : side === "start" ? 12 : 0;
        return (
          <g key={`n-${i}`} className="node" style={{ animationDelay: `${i * 0.35}s` }}>
            <circle cx={n.x} cy={n.y} r="9" fill={primaryColor} opacity="0.18" />
            <circle cx={n.x} cy={n.y} r="4" fill={primaryColor} filter="url(#glow)" />
            <text
              x={n.x + dx}
              y={n.y + 5}
              textAnchor={side}
              className="node-value"
              fill="#f4f8ff"
            >
              {n.value}
            </text>
            <text
              x={n.x + dx}
              y={n.y - 11}
              textAnchor={side}
              className="node-label"
              fill={primaryColor}
            >
              {n.label}
            </text>
          </g>
        );
      })}

      {/* avatar */}
      <circle cx={CX} cy={CY} r={R + 5} fill="none" stroke={primaryColor} strokeWidth="2" opacity="0.5" />
      <circle cx={CX} cy={CY} r={R} fill={`url(#${gid})`} />
      {player.photo && (
        <image
          href={player.photo}
          x={CX - R}
          y={CY - R}
          width={R * 2}
          height={R * 2}
          clipPath={`url(#${clip})`}
          preserveAspectRatio="xMidYMid slice"
        />
      )}
      {!player.photo && (
        <g clipPath={`url(#${clip})`} textAnchor="middle">
          <text x={CX} y={CY + 2} className="avatar-number" fill="#ffffff">
            {player.number ?? ""}
          </text>
          <text x={CX} y={CY + 30} className="avatar-initials" fill="#ffffff">
            {initials(player.name)}
          </text>
        </g>
      )}
      <circle cx={CX} cy={CY} r={R} fill="none" stroke="#0a1930" strokeWidth="1" opacity="0.6" />
    </svg>
  );
}
