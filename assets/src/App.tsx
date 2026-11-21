import { useCallback, useEffect, useMemo, useState } from "react";
import { fetchTeams } from "./api";
import type { Team, Player } from "./types";
import TeamSelector from "./components/TeamSelector";
import PlayerCircuit from "./components/PlayerCircuit";
import PlayerModal from "./components/PlayerModal";
import AddTeamModal from "./components/AddTeamModal";
import AddPlayerModal from "./components/AddPlayerModal";

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
  const [modalPlayer, setModalPlayer] = useState<Player | null>(null);
  const [showAddTeam, setShowAddTeam] = useState(false);
  const [showAddPlayer, setShowAddPlayer] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  // Load teams; optionally select a team by name (after adding one).
  const load = useCallback(async (selectName?: string) => {
    const { teams } = await fetchTeams();
    setTeams(teams);
    setSelectedId((cur) => {
      if (selectName) {
        const found = teams.find((t) => t.name === selectName);
        if (found) return found.id;
      }
      return cur ?? teams[0]?.id ?? null;
    });
  }, []);

  useEffect(() => {
    load()
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, [load]);

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
            <>
              <div className="squad-toolbar">
                <h2 className="squad-title">
                  {selected.name}{" "}
                  <span>
                    · {selected.players.length}{" "}
                    {selected.players.length === 1 ? "player" : "players"}
                  </span>
                </h2>
                <div className="squad-actions">
                  <button className="btn-add" onClick={() => setShowAddPlayer(true)}>
                    + Add Player
                  </button>
                  <button className="btn-add" onClick={() => setShowAddTeam(true)}>
                    + Add Team
                  </button>
                </div>
              </div>

              <main className="player-grid">
                {selected.players.map((player) => (
                  <article
                    className="player-card"
                    key={player.id}
                    onClick={() => setModalPlayer(player)}
                    title={`View ${player.name}'s profile`}
                  >
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
            </>
          )}
        </>
      )}

      {modalPlayer && selected && (
        <PlayerModal
          player={modalPlayer}
          teamName={selected.name}
          primaryColor={primary}
          onClose={() => setModalPlayer(null)}
        />
      )}

      {showAddTeam && (
        <AddTeamModal
          onClose={() => setShowAddTeam(false)}
          onAdded={async (teamName) => {
            setShowAddTeam(false);
            await load(teamName);
          }}
        />
      )}

      {showAddPlayer && selected && (
        <AddPlayerModal
          teamId={selected.id}
          teamName={selected.name}
          onClose={() => setShowAddPlayer(false)}
          onAdded={async () => {
            setShowAddPlayer(false);
            await load();
          }}
        />
      )}

      <footer className="app-footer">
        Data: API-Football &amp; Wikipedia · {selected?.players.length ?? 0} players shown ·
        click a player for their profile
      </footer>
    </div>
  );
}
