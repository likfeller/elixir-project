import type { Team, CatalogTeam } from "./types";

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
        description
        seasonHistory {
          season
          team
          league
          competitionType
          appearances
          goals
          assists
          minutes
          rating
        }
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

export function fetchCatalogTeams(): Promise<{ catalogTeams: CatalogTeam[] }> {
  return gql(`
    query CatalogTeams {
      catalogTeams { apiId name league logo primaryColor secondaryColor }
    }
  `);
}

export function addTeam(apiId: number): Promise<{ addTeam: { id: string; name: string } }> {
  return gql(`mutation ($apiId: Int!) { addTeam(apiId: $apiId) { id name } }`, { apiId });
}

export function addPlayer(
  teamId: string,
  name: string
): Promise<{ addPlayer: { id: string; name: string } }> {
  return gql(`mutation ($teamId: ID!, $name: String!) { addPlayer(teamId: $teamId, name: $name) { id name } }`, {
    teamId,
    name,
  });
}
