import { useEffect, useMemo, useState } from "react";
import { fetchTeams } from "./api";
import type { Team } from "./types";
import TeamSelector from "./components/TeamSelector";
import PlayerCircuit from "./components/PlayerCircuit";

// Ghosted footballer silhouette shown behind a card until a real photo exists.
const FALLBACK_PHOTO =
  "data:image/svg+xml;utf8," +
  encodeURIComponent(
    `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 220'>
       <circle cx='100' cy='58' r='36' fill='#9fb6d8'/>
       <path d='M30 220 C30 150 64 116 100 116 C136 116 170 150 170 220 Z' fill='#9fb6d8'/>
     </svg>`
  );

export default function App() {
  const [teams, setTeams] = useState<Team[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchTeams()
      .then(({ teams }) => {
        setTeams(teams);
        setSelectedId((cur) => cur ?? teams[0]?.id ?? null);
      })
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  const selected = useMemo(
    () => teams.find((t) => t.id === selectedId) ?? null,
    [teams, selectedId]
  );

  const primary = selected?.primaryColor ?? "#febe10";
  const secondary = selected?.secondaryColor ?? "#1b3a6b";

  return (
    <div className="app" style={{ ["--accent" as string]: primary }}>
      <header className="app-header">
        <div className="app-title">
          <span className="ball">⚽</span>
          <div>
            <h1>Football Analytics</h1>
            <p>Circuit HUD · player performance over the season</p>
          </div>
        </div>
        {selected && (
          <div className="app-team-badge">
            {selected.logo && <img src={selected.logo} alt="" />}
            <div>
              <strong>{selected.name}</strong>
              <span>{selected.leagueName}</span>
            </div>
          </div>
        )}
      </header>

      {loading && <div className="status">Loading teams…</div>}
      {error && <div className="status error">Error: {error}</div>}

      {!loading && !error && (
        <>
          <TeamSelector teams={teams} selectedId={selectedId} onSelect={setSelectedId} />

          {selected && (
            <main className="player-grid">
              {selected.players.map((player) => (
                <article className="player-card" key={player.id}>
                  <div
                    className="player-card-bg"
                    style={{ backgroundImage: `url("${player.photo ?? FALLBACK_PHOTO}")` }}
                  />
                  <PlayerCircuit
                    player={player}
                    primaryColor={primary}
                    secondaryColor={secondary}
                  />
                  <div className="player-caption">
                    <span className="player-num" style={{ color: primary }}>
                      #{player.number ?? "—"}
                    </span>
                    <span className="player-name">{player.name}</span>
                    <span className="player-meta">
                      {player.position} · {player.nationality}
                    </span>
                  </div>
                </article>
              ))}
            </main>
          )}
        </>
      )}

      <footer className="app-footer">
        Data: API-Football · {selected?.players.length ?? 0} players shown
      </footer>
    </div>
  );
}
