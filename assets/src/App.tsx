import { useCallback, useEffect, useMemo, useState } from "react";
import { fetchTeams, setFavorite, removePlayer } from "./api";
import type { Team, Player } from "./types";
import TeamSelector from "./components/TeamSelector";
import PlayerCard from "./components/PlayerCard";
import PlayerModal from "./components/PlayerModal";
import AddTeamModal from "./components/AddTeamModal";
import AddPlayerModal from "./components/AddPlayerModal";
import Pitch from "./components/Pitch";

type View = "teams" | "favorites";
const MAX_XI = 11;

export default function App() {
  const [teams, setTeams] = useState<Team[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [view, setView] = useState<View>("teams");
  const [modalPlayer, setModalPlayer] = useState<Player | null>(null);
  const [showAddTeam, setShowAddTeam] = useState(false);
  const [showAddPlayer, setShowAddPlayer] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [notice, setNotice] = useState<string | null>(null);

  const showNotice = (msg: string) => {
    setNotice(msg);
    window.setTimeout(() => setNotice((cur) => (cur === msg ? null : cur)), 3500);
  };

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

  // Favorites across all teams, each paired with its team for theming.
  const favorites = useMemo(
    () =>
      teams.flatMap((t) =>
        t.players.filter((p) => p.favorite).map((p) => ({ player: p, team: t }))
      ),
    [teams]
  );

  const primary = selected?.primaryColor ?? "#febe10";
  const secondary = selected?.secondaryColor ?? "#1b3a6b";

  const toggleFavorite = async (p: Player) => {
    if (!p.favorite && favorites.length >= MAX_XI) {
      showNotice(`Your starting XI is full (${MAX_XI}). Remove one to add another.`);
      return;
    }
    try {
      await setFavorite(p.id, !p.favorite);
      await load();
    } catch (e) {
      showNotice((e as Error).message);
    }
  };

  const remove = async (p: Player) => {
    await removePlayer(p.id);
    if (modalPlayer?.id === p.id) setModalPlayer(null);
    await load();
  };

  return (
    <div className="app" style={{ ["--accent" as string]: primary }}>
      {view === "teams" && selected?.logo && (
        <div
          className="team-backdrop"
          style={{ backgroundImage: `url("${selected.logo}")` }}
        />
      )}

      <header className="app-header">
        <div className="app-title">
          <span className="ball">⚽</span>
          <div>
            <h1>Football Analytics</h1>
            <p>Circuit HUD · player performance over the season</p>
          </div>
        </div>

        <div className="header-right">
          <button
            className={`fav-star ${view === "favorites" ? "active" : ""}`}
            title="Favorite players"
            onClick={() => setView(view === "favorites" ? "teams" : "favorites")}
          >
            <span className="fav-star-icon">★</span>
            {favorites.length > 0 && <span className="fav-star-count">{favorites.length}</span>}
          </button>

          {view === "teams" && selected && (
            <div className="app-team-badge">
              {selected.logo && <img src={selected.logo} alt="" />}
              <div>
                <strong>{selected.name}</strong>
                <span>{selected.leagueName}</span>
              </div>
            </div>
          )}
        </div>
      </header>

      {loading && <div className="status">Loading teams…</div>}
      {error && <div className="status error">Error: {error}</div>}

      {/* ---- Favorites view: starting XI on a pitch ---- */}
      {!loading && !error && view === "favorites" && (
        <>
          <div className="squad-toolbar">
            <h2 className="squad-title">
              ★ Starting XI <span>· 4-3-3 · {favorites.length}/{MAX_XI}</span>
            </h2>
            <button className="btn-add" onClick={() => setView("teams")}>← Back to teams</button>
          </div>

          <Pitch favorites={favorites} onOpen={setModalPlayer} onRemove={toggleFavorite} />

          {favorites.length === 0 && (
            <div className="status">
              Your XI is empty. Go to a team and tap the ☆ on players to pick your eleven.
            </div>
          )}
        </>
      )}

      {/* ---- Teams view ---- */}
      {!loading && !error && view === "teams" && (
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
                  <button className="btn-add" onClick={() => setShowAddPlayer(true)}>+ Add Player</button>
                  <button className="btn-add" onClick={() => setShowAddTeam(true)}>+ Add Team</button>
                </div>
              </div>

              <main className="player-grid">
                {selected.players.map((player) => (
                  <PlayerCard
                    key={player.id}
                    player={player}
                    primaryColor={primary}
                    secondaryColor={secondary}
                    onOpen={setModalPlayer}
                    onToggleFavorite={toggleFavorite}
                    onRemove={remove}
                  />
                ))}
              </main>
            </>
          )}
        </>
      )}

      {modalPlayer && (
        <PlayerModal
          player={modalPlayer}
          teamName={
            teams.find((t) => t.players.some((p) => p.id === modalPlayer.id))?.name ?? ""
          }
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

      {notice && <div className="notice-toast">{notice}</div>}

      <footer className="app-footer">
        Data: API-Football &amp; Wikipedia · click a player for their profile · ☆ to favorite
      </footer>
    </div>
  );
}
