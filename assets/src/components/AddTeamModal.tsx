import { useEffect, useMemo, useState } from "react";
import { fetchCatalogTeams, addTeam } from "../api";
import type { CatalogTeam } from "../types";

interface Props {
  onClose: () => void;
  onAdded: (teamName: string) => void;
}

export default function AddTeamModal({ onClose, onAdded }: Props) {
  const [catalog, setCatalog] = useState<CatalogTeam[]>([]);
  const [league, setLeague] = useState<string>("");
  const [apiId, setApiId] = useState<number | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchCatalogTeams()
      .then(({ catalogTeams }) => {
        setCatalog(catalogTeams);
        if (catalogTeams[0]) setLeague(catalogTeams[0].league);
      })
      .catch((e) => setError(e.message));
  }, []);

  const leagues = useMemo(
    () => Array.from(new Set(catalog.map((t) => t.league))),
    [catalog]
  );
  const teamsInLeague = useMemo(
    () => catalog.filter((t) => t.league === league),
    [catalog, league]
  );

  const submit = async () => {
    if (!apiId) return;
    setBusy(true);
    setError(null);
    try {
      const chosen = catalog.find((t) => t.apiId === apiId);
      await addTeam(apiId);
      onAdded(chosen?.name ?? "team");
    } catch (e) {
      setError((e as Error).message);
      setBusy(false);
    }
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal modal-sm" onClick={(e) => e.stopPropagation()}>
        <button className="modal-close" onClick={onClose} aria-label="Close">×</button>
        <h2 className="form-title">Add a team</h2>
        <p className="form-sub">Pick a club from a top-5 league.</p>

        {error && <div className="form-error">{error}</div>}

        <label className="form-label">League</label>
        <select
          className="form-select"
          value={league}
          onChange={(e) => {
            setLeague(e.target.value);
            setApiId(null);
          }}
        >
          {leagues.map((l) => (
            <option key={l} value={l}>{l}</option>
          ))}
        </select>

        <label className="form-label">Team</label>
        <select
          className="form-select"
          value={apiId ?? ""}
          onChange={(e) => setApiId(Number(e.target.value))}
        >
          <option value="" disabled>Select a team…</option>
          {teamsInLeague.map((t) => (
            <option key={t.apiId} value={t.apiId}>{t.name}</option>
          ))}
        </select>

        <div className="form-actions">
          <button className="btn-ghost" onClick={onClose} disabled={busy}>Cancel</button>
          <button className="btn-primary" onClick={submit} disabled={!apiId || busy}>
            {busy ? "Adding…" : "Add team"}
          </button>
        </div>
      </div>
    </div>
  );
}
