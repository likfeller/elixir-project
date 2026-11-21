import type { Team } from "../types";

interface Props {
  teams: Team[];
  selectedId: string | null;
  onSelect: (id: string) => void;
}

export default function TeamSelector({ teams, selectedId, onSelect }: Props) {
  const clubs = teams.filter((t) => t.type !== "national");
  const nationals = teams.filter((t) => t.type === "national");

  const renderGroup = (label: string, group: Team[]) => (
    <div className="selector-group">
      <span className="selector-group-label">{label}</span>
      <div className="selector-chips">
        {group.map((team) => (
          <button
            key={team.id}
            className={`team-chip ${selectedId === team.id ? "active" : ""}`}
            style={{ ["--team-color" as string]: team.primaryColor ?? "#888" }}
            onClick={() => onSelect(team.id)}
          >
            {team.logo && (
              <img
                className="team-chip-logo"
                src={team.logo}
                alt=""
                onError={(e) => ((e.target as HTMLImageElement).style.display = "none")}
              />
            )}
            <span>{team.name}</span>
          </button>
        ))}
      </div>
    </div>
  );

  return (
    <nav className="team-selector">
      {clubs.length > 0 && renderGroup("Clubs", clubs)}
      {nationals.length > 0 && renderGroup("National Teams", nationals)}
    </nav>
  );
}
