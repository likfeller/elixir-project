import type { Player } from "../types";
import PlayerCircuit from "./PlayerCircuit";

// Ghosted footballer silhouette shown behind a card until a real photo exists.
const FALLBACK_PHOTO =
  "data:image/svg+xml;utf8," +
  encodeURIComponent(
    `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 220'>
       <circle cx='100' cy='58' r='36' fill='#9fb6d8'/>
       <path d='M30 220 C30 150 64 116 100 116 C136 116 170 150 170 220 Z' fill='#9fb6d8'/>
     </svg>`
  );

interface Props {
  player: Player;
  primaryColor: string;
  secondaryColor: string;
  onOpen: (player: Player) => void;
  onToggleFavorite: (player: Player) => void;
  onRemove: (player: Player) => void;
}

export default function PlayerCard({
  player,
  primaryColor,
  secondaryColor,
  onOpen,
  onToggleFavorite,
  onRemove,
}: Props) {
  return (
    <article
      className="player-card"
      onClick={() => onOpen(player)}
      title={`View ${player.name}'s profile`}
    >
      <div
        className="player-card-bg"
        style={{ backgroundImage: `url("${player.photo ?? FALLBACK_PHOTO}")` }}
      />

      {/* remove (shown on hover) */}
      <button
        className="card-remove"
        title="Remove player"
        aria-label="Remove player"
        onClick={(e) => {
          e.stopPropagation();
          onRemove(player);
        }}
      >
        ×
      </button>

      {/* favorite toggle */}
      <button
        className={`card-fav ${player.favorite ? "active" : ""}`}
        title={player.favorite ? "Remove from favorites" : "Add to favorites"}
        aria-label="Toggle favorite"
        style={player.favorite ? { color: primaryColor } : undefined}
        onClick={(e) => {
          e.stopPropagation();
          onToggleFavorite(player);
        }}
      >
        {player.favorite ? "★" : "☆"}
      </button>

      <PlayerCircuit player={player} primaryColor={primaryColor} secondaryColor={secondaryColor} />

      <div className="player-caption">
        <span className="player-num" style={{ color: primaryColor }}>
          #{player.number ?? "—"}
        </span>
        <span className="player-name">{player.name}</span>
        <span className="player-meta">
          {player.position} · {player.nationality}
        </span>
      </div>
    </article>
  );
}
