import { useEffect, useMemo, useRef, useState } from "react";
import type { Player, Team } from "../types";

interface Entry {
  player: Player;
  team: Team;
}

interface Props {
  favorites: Entry[];
  onOpen: (player: Player) => void;
  onRemove: (player: Player) => void;
}

type Role = "GK" | "DEF" | "MID" | "ATT";

interface Slot {
  role: Role;
  x: number; // % left
  y: number; // % top (0 = attack end / top, 100 = own goal / bottom)
}

// 4-3-3, vertical pitch (GK at the bottom, attack towards the top).
const SLOTS: Slot[] = [
  { role: "GK", x: 50, y: 90 },
  { role: "DEF", x: 16, y: 71 },
  { role: "DEF", x: 39, y: 74 },
  { role: "DEF", x: 61, y: 74 },
  { role: "DEF", x: 84, y: 71 },
  { role: "MID", x: 27, y: 50 },
  { role: "MID", x: 50, y: 52 },
  { role: "MID", x: 73, y: 50 },
  { role: "ATT", x: 24, y: 25 },
  { role: "ATT", x: 50, y: 20 },
  { role: "ATT", x: 76, y: 25 },
];

const STORAGE_KEY = "xi-arrangement-433";
const MOVE_THRESHOLD = 6;

function roleOf(position: string | null): Role {
  switch (position) {
    case "Goalkeeper":
      return "GK";
    case "Defender":
      return "DEF";
    case "Attacker":
      return "ATT";
    default:
      return "MID";
  }
}

function loadSaved(): (string | null)[] | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const arr = JSON.parse(raw);
    return Array.isArray(arr) ? arr : null;
  } catch {
    return null;
  }
}

function reconcile(base: (string | null)[] | null, favorites: Entry[]): (string | null)[] {
  const favIds = new Set(favorites.map((e) => e.player.id));
  const slots: (string | null)[] = new Array(SLOTS.length).fill(null);

  if (base) {
    base.forEach((id, i) => {
      if (i < slots.length && id && favIds.has(id) && !slots.includes(id)) {
        slots[i] = id;
      }
    });
  }

  const remaining = favorites.filter((e) => !slots.includes(e.player.id));

  SLOTS.forEach((slot, i) => {
    if (slots[i]) return;
    const k = remaining.findIndex((e) => e && roleOf(e.player.position) === slot.role);
    if (k >= 0) {
      slots[i] = remaining[k].player.id;
      remaining[k] = null as unknown as Entry;
    }
  });

  SLOTS.forEach((_slot, i) => {
    if (slots[i]) return;
    const k = remaining.findIndex((e) => e);
    if (k >= 0) {
      slots[i] = remaining[k].player.id;
      remaining[k] = null as unknown as Entry;
    }
  });

  return slots;
}

export default function Pitch({ favorites, onOpen, onRemove }: Props) {
  const byId = useMemo(() => {
    const m: Record<string, Entry> = {};
    favorites.forEach((e) => (m[e.player.id] = e));
    return m;
  }, [favorites]);

  const pitchRef = useRef<HTMLDivElement>(null);
  const [arrangement, setArrangement] = useState<(string | null)[]>(() =>
    reconcile(loadSaved(), favorites)
  );
  const dragRef = useRef<{ from: number; id: string; startX: number; startY: number; moved: boolean } | null>(null);
  const [ghost, setGhost] = useState<{ x: number; y: number; id: string } | null>(null);
  const [overSlot, setOverSlot] = useState<number | null>(null);
  const [sourceSlot, setSourceSlot] = useState<number | null>(null);

  useEffect(() => {
    setArrangement((prev) => reconcile(prev, favorites));
  }, [favorites]);

  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(arrangement));
    } catch {
      /* ignore */
    }
  }, [arrangement]);

  const nearestSlot = (x: number, y: number): number | null => {
    const el = pitchRef.current;
    if (!el) return null;
    const rect = el.getBoundingClientRect();
    let best: number | null = null;
    let bestDist = Infinity;
    SLOTS.forEach((s, i) => {
      const cx = rect.left + (s.x / 100) * rect.width;
      const cy = rect.top + (s.y / 100) * rect.height;
      const d = (cx - x) ** 2 + (cy - y) ** 2;
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    });
    return bestDist <= 90 * 90 ? best : null;
  };

  const startDrag = (e: React.PointerEvent, slotIndex: number, id: string) => {
    if (e.button !== 0 && e.pointerType === "mouse") return;
    dragRef.current = { from: slotIndex, id, startX: e.clientX, startY: e.clientY, moved: false };

    const move = (ev: PointerEvent) => {
      const d = dragRef.current;
      if (!d) return;
      if (!d.moved && Math.hypot(ev.clientX - d.startX, ev.clientY - d.startY) > MOVE_THRESHOLD) {
        d.moved = true;
        setSourceSlot(d.from);
      }
      if (d.moved) {
        setGhost({ x: ev.clientX, y: ev.clientY, id: d.id });
        setOverSlot(nearestSlot(ev.clientX, ev.clientY));
      }
    };

    const up = (ev: PointerEvent) => {
      window.removeEventListener("pointermove", move);
      window.removeEventListener("pointerup", up);
      const d = dragRef.current;
      dragRef.current = null;
      setGhost(null);
      setOverSlot(null);
      setSourceSlot(null);
      if (!d) return;

      if (d.moved) {
        const target = nearestSlot(ev.clientX, ev.clientY);
        if (target !== null && target !== d.from) {
          setArrangement((arr) => {
            const next = [...arr];
            const tmp = next[target];
            next[target] = next[d.from];
            next[d.from] = tmp;
            return next;
          });
        }
      } else {
        const entry = byId[d.id];
        if (entry) onOpen(entry.player);
      }
    };

    window.addEventListener("pointermove", move);
    window.addEventListener("pointerup", up);
  };

  const ghostEntry = ghost ? byId[ghost.id] : null;

  return (
    <div className="pitch-wrap">
      <div className="pitch" ref={pitchRef}>
        <div className="pitch-line pitch-halfway" />
        <div className="pitch-circle" />
        <div className="pitch-spot" />
        <div className="pitch-box pitch-box-top" />
        <div className="pitch-box pitch-box-bottom" />
        <div className="pitch-arc pitch-arc-top" />
        <div className="pitch-arc pitch-arc-bottom" />

        {SLOTS.map((slot, i) => {
          const id = arrangement[i];
          const entry = id ? byId[id] : null;
          return (
            <div
              key={i}
              className={`pitch-slot ${overSlot === i ? "drag-over" : ""}`}
              style={{ left: `${slot.x}%`, top: `${slot.y}%` }}
            >
              {entry ? (
                <div
                  className={`token ${sourceSlot === i ? "dragging" : ""}`}
                  onPointerDown={(e) => startDrag(e, i, entry.player.id)}
                  title={`${entry.player.name} — tap for profile, drag to move`}
                >
                  <button
                    className="token-remove"
                    title="Remove from XI"
                    aria-label="Remove from XI"
                    onPointerDown={(e) => e.stopPropagation()}
                    onClick={(e) => {
                      e.stopPropagation();
                      onRemove(entry.player);
                    }}
                  >
                    ×
                  </button>
                  <TokenFace entry={entry} slotRole={slot.role} />
                </div>
              ) : (
                <div className="token-empty" title={`${slot.role} — drop a player here`}>
                  <span>{slot.role}</span>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {ghost && ghostEntry && (
        <div className="token-ghost" style={{ left: ghost.x, top: ghost.y }}>
          <TokenFace entry={ghostEntry} slotRole={roleOf(ghostEntry.player.position)} />
        </div>
      )}
    </div>
  );
}

function TokenFace({ entry, slotRole }: { entry: Entry; slotRole: Role }) {
  const { player, team } = entry;
  const color = team.primaryColor ?? "#febe10";
  const outOfPosition = roleOf(player.position) !== slotRole;

  return (
    <>
      <div className="token-photo" style={{ borderColor: color, boxShadow: `0 0 14px -4px ${color}` }}>
        {player.photo ? (
          <img src={player.photo} alt={player.name} draggable={false} />
        ) : (
          <span className="token-num">{player.number ?? "?"}</span>
        )}
        {outOfPosition && <span className="token-oop" title="Playing out of position">⚑</span>}
      </div>
      <div className="token-name">{player.name}</div>
      <div className="token-sub" style={{ color }}>
        {player.number ? `#${player.number}` : slotRole}
      </div>
    </>
  );
}
