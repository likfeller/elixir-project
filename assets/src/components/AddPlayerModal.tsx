import { useState } from "react";
import { addPlayer } from "../api";

interface Props {
  teamId: string;
  teamName: string;
  onClose: () => void;
  onAdded: (playerName: string) => void;
}

export default function AddPlayerModal({ teamId, teamName, onClose, onAdded }: Props) {
  const [name, setName] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const submit = async () => {
    const trimmed = name.trim();
    if (!trimmed) return;
    setBusy(true);
    setError(null);
    try {
      await addPlayer(teamId, trimmed);
      onAdded(trimmed);
    } catch (e) {
      setError((e as Error).message);
      setBusy(false);
    }
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal modal-sm" onClick={(e) => e.stopPropagation()}>
        <button className="modal-close" onClick={onClose} aria-label="Close">×</button>
        <h2 className="form-title">Add a player</h2>
        <p className="form-sub">
          Add any footballer to <strong>{teamName}</strong>. Their photo and profile
          are pulled from Wikipedia automatically.
        </p>

        {error && <div className="form-error">{error}</div>}

        <label className="form-label">Player name</label>
        <input
          className="form-input"
          type="text"
          placeholder="e.g. Zlatan Ibrahimovic"
          value={name}
          autoFocus
          onChange={(e) => setName(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && submit()}
          disabled={busy}
        />

        <div className="form-actions">
          <button className="btn-ghost" onClick={onClose} disabled={busy}>Cancel</button>
          <button className="btn-primary" onClick={submit} disabled={!name.trim() || busy}>
            {busy ? "Adding…" : "Add player"}
          </button>
        </div>
      </div>
    </div>
  );
}
