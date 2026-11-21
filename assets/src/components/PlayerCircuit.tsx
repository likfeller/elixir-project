import { useMemo } from "react";
import type { Player } from "../types";

interface Props {
  player: Player;
  primaryColor: string;
  secondaryColor: string;
}

// viewBox geometry
const W = 380;
const H = 470;
const CX = 190; // avatar center x
const CY = 360; // avatar center y
const R = 56; // avatar radius
const ANCHOR_X = CX;
const ANCHOR_Y = CY - R - 4; // where traces leave the head

const CHIP_W = 92;
const CHIP_H = 40;

interface Stat {
  label: string;
  value: string;
  // chip top-left corner
  cx: number;
  cy: number;
}

// The point on a chip's edge that faces the head anchor (where the trace lands).
function port(s: Stat): [number, number] {
  const centerX = s.cx + CHIP_W / 2;
  if (Math.abs(centerX - ANCHOR_X) < 30) return [centerX, s.cy + CHIP_H]; // top chip → bottom edge
  if (centerX < ANCHOR_X) return [s.cx + CHIP_W, s.cy + CHIP_H / 2]; // left chip → right edge
  return [s.cx, s.cy + CHIP_H / 2]; // right chip → left edge
}

// Route a PCB-style trace from the head anchor up to a port:
// vertical riser → 45° bevel → horizontal run into the chip.
function trace(px: number, py: number): string {
  const bevel = Math.min(18, Math.abs(px - ANCHOR_X));
  const sgn = px >= ANCHOR_X ? 1 : -1;
  if (bevel < 2) return `M ${ANCHOR_X},${ANCHOR_Y} L ${px},${py}`;
  return [
    `M ${ANCHOR_X},${ANCHOR_Y}`,
    `L ${ANCHOR_X},${py + bevel}`,
    `L ${ANCHOR_X + sgn * bevel},${py}`,
    `L ${px},${py}`,
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
  const stats = useMemo<Stat[]>(
    () => [
      { label: "GOALS", value: String(player.goals), cx: 14, cy: 96 },
      { label: "DRIBBLES", value: String(player.dribblesSuccess), cx: 144, cy: 36 },
      { label: "RATING", value: player.rating ? player.rating.toFixed(1) : "—", cx: 274, cy: 96 },
      { label: "ASSISTS", value: String(player.assists), cx: 8, cy: 188 },
      { label: "PASS %", value: `${player.passAccuracy}%`, cx: 280, cy: 188 },
      { label: "SHOTS", value: `${player.shotsOn}/${player.shotsTotal}`, cx: 250, cy: 262 },
    ],
    [player]
  );

  const gid = `grad-${player.id}`;
  const clip = `clip-${player.id}`;

  return (
    <svg className="player-circuit" viewBox={`0 0 ${W} ${H}`} role="img" aria-label={player.name}>
      <defs>
        <radialGradient id={gid} cx="50%" cy="35%" r="75%">
          <stop offset="0%" stopColor={primaryColor} stopOpacity="0.95" />
          <stop offset="100%" stopColor={secondaryColor} stopOpacity="0.95" />
        </radialGradient>
        <clipPath id={clip}>
          <circle cx={CX} cy={CY} r={R} />
        </clipPath>
        <filter id={`glow-${player.id}`} x="-60%" y="-60%" width="220%" height="220%">
          <feGaussianBlur stdDeviation="3" result="b" />
          <feMerge>
            <feMergeNode in="b" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      {/* scrim: darken the upper area so chips/traces pop over the photo */}
      <rect x="0" y="0" width={W} height="300" fill="#060f1f" opacity="0.38" />

      {/* traces from head to each stat chip */}
      {stats.map((s, i) => {
        const [px, py] = port(s);
        return (
          <path
            key={`t-${i}`}
            className="trace"
            d={trace(px, py)}
            stroke={primaryColor}
            style={{ animationDelay: `${i * 0.3}s` }}
          />
        );
      })}

      {/* stat chips */}
      {stats.map((s, i) => {
        const [px, py] = port(s);
        const midX = s.cx + CHIP_W / 2;
        return (
          <g key={`c-${i}`}>
            {/* connection dot */}
            <circle cx={px} cy={py} r="7" fill={primaryColor} opacity="0.25" />
            <circle
              cx={px}
              cy={py}
              r="4"
              fill={primaryColor}
              filter={`url(#glow-${player.id})`}
            />
            {/* chip */}
            <rect
              x={s.cx}
              y={s.cy}
              width={CHIP_W}
              height={CHIP_H}
              rx="9"
              fill="#0a1830"
              fillOpacity="0.9"
              stroke={primaryColor}
              strokeWidth="1.5"
            />
            <text x={midX} y={s.cy + 15} textAnchor="middle" className="chip-label" fill={primaryColor}>
              {s.label}
            </text>
            <text x={midX} y={s.cy + 33} textAnchor="middle" className="chip-value" fill="#f4f8ff">
              {s.value}
            </text>
          </g>
        );
      })}

      {/* avatar */}
      <circle cx={CX} cy={CY} r={R + 6} fill="none" stroke={primaryColor} strokeWidth="2.5" opacity="0.55" />
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
          <text x={CX} y={CY + 4} className="avatar-number" fill="#ffffff">
            {player.number ?? ""}
          </text>
          <text x={CX} y={CY + 32} className="avatar-initials" fill="#ffffff">
            {initials(player.name)}
          </text>
        </g>
      )}
      <circle cx={CX} cy={CY} r={R} fill="none" stroke="#0a1930" strokeWidth="1" opacity="0.6" />
    </svg>
  );
}
