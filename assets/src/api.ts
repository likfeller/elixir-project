import type { Team } from "./types";

// Minimal GraphQL fetch helper — no heavy client needed for this dashboard.
async function gql<T>(query: string, variables: Record<string, unknown> = {}): Promise<T> {
  const res = await fetch("/api/graphql", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query, variables }),
  });
  if (!res.ok) throw new Error(`GraphQL HTTP ${res.status}`);
  const json = await res.json();
  if (json.errors) throw new Error(json.errors.map((e: { message: string }) => e.message).join("; "));
  return json.data as T;
}

const TEAMS_QUERY = `
  query Teams {
    teams {
      id
      name
      code
      country
      logo
      type
      leagueName
      primaryColor
      secondaryColor
      players {
        id
        name
        number
        position
        age
        nationality
        photo
        appearances
        minutes
        goals
        assists
        shotsTotal
        shotsOn
        passesTotal
        passesKey
        passAccuracy
        dribblesAttempts
        dribblesSuccess
        tackles
        duelsTotal
        duelsWon
        rating
      }
    }
  }
`;

export function fetchTeams(): Promise<{ teams: Team[] }> {
  return gql<{ teams: Team[] }>(TEAMS_QUERY);
}
