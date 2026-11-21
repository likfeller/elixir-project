import { useEffect } from "react";
import type { Player } from "../types";

interface Props {
  player: Player;
  teamName: string;
  primaryColor: string;
  onClose: () => void;
}

export default function PlayerModal({ player, teamName, primaryColor, onClose }: Props) {
  // Close on Escape.
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  const seasons = player.seasonHistory ?? [];

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div
        className="modal"
        style={{ ["--accent" as string]: primaryColor }}
        onClick={(e) => e.stopPropagation()}
      >
        <button className="modal-close" onClick={onClose} aria-label="Close">
          ×
        </button>

        <div className="modal-head">
          <div className="modal-photo" style={{ borderColor: primaryColor }}>
            {player.photo ? (
              <img src={player.photo} alt={player.name} />
            ) : (
              <span className="modal-photo-num">{player.number ?? ""}</span>
            )}
          </div>
          <div className="modal-head-info">
            <span className="modal-num" style={{ color: primaryColor }}>
              #{player.number ?? "—"} · {teamName}
            </span>
            <h2>{player.name}</h2>
            <span className="modal-meta">
              {player.position} · {player.nationality}
              {player.age ? ` · ${player.age} yrs` : ""}
            </span>
          </div>
        </div>

        {/* quick stat strip for the current season */}
        <div className="modal-statstrip">
          <Stat label="Goals" value={player.goals} accent={primaryColor} />
          <Stat label="Assists" value={player.assists} accent={primaryColor} />
          <Stat label="Apps" value={player.appearances} accent={primaryColor} />
          <Stat
            label="Rating"
            value={player.rating ? player.rating.toFixed(1) : "—"}
            accent={primaryColor}
          />
        </div>

        {player.description && (
          <section className="modal-section">
            <h3>Profile</h3>
            <p className="modal-desc">{player.description}</p>
          </section>
        )}

        <section className="modal-section">
          <h3>Recent seasons</h3>
          {seasons.length === 0 ? (
            <p className="modal-empty">
              Season history will load from API-Football once an API key is configured
              (<code>config/dev.secret.exs</code>).
            </p>
          ) : (
            <table className="season-table">
              <thead>
                <tr>
                  <th>Season</th>
                  <th>Team</th>
                  <th>Competition</th>
                  <th className="num">Apps</th>
                  <th className="num">Goals</th>
                  <th className="num">Assists</th>
                  <th className="num">Rating</th>
                </tr>
              </thead>
              <tbody>
                {seasons.map((s, i) => (
                  <tr key={i} className={s.competitionType === "national" ? "intl" : ""}>
                    <td>{s.season ?? "—"}</td>
                    <td>{s.team ?? "—"}</td>
                    <td>{s.league ?? "—"}</td>
                    <td className="num">{s.appearances ?? "—"}</td>
                    <td className="num">{s.goals ?? "—"}</td>
                    <td className="num">{s.assists ?? "—"}</td>
                    <td className="num">{s.rating ? s.rating.toFixed(1) : "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </section>
      </div>
    </div>
  );
}

function Stat({
  label,
  value,
  accent,
}: {
  label: string;
  value: number | string | null;
  accent: string;
}) {
  return (
    <div className="modal-stat">
      <span className="modal-stat-value" style={{ color: accent }}>
        {value ?? "—"}
      </span>
      <span className="modal-stat-label">{label}</span>
    </div>
  );
}
