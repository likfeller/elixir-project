export interface SeasonStat {
  season: number | null;
  team: string | null;
  league: string | null;
  competitionType: string | null;
  appearances: number | null;
  goals: number | null;
  assists: number | null;
  minutes: number | null;
  rating: number | null;
}

export interface Player {
  id: string;
  name: string;
  description: string | null;
  seasonHistory: SeasonStat[];
  number: number | null;
  position: string | null;
  age: number | null;
  nationality: string | null;
  photo: string | null;
  appearances: number;
  minutes: number;
  goals: number;
  assists: number;
  shotsTotal: number;
  shotsOn: number;
  passesTotal: number;
  passesKey: number;
  passAccuracy: number;
  dribblesAttempts: number;
  dribblesSuccess: number;
  tackles: number;
  duelsTotal: number;
  duelsWon: number;
  rating: number | null;
}

export interface CatalogTeam {
  apiId: number;
  name: string;
  league: string;
  logo: string | null;
  primaryColor: string | null;
  secondaryColor: string | null;
}

export interface Team {
  id: string;
  name: string;
  code: string | null;
  country: string | null;
  logo: string | null;
  type: string | null;
  leagueName: string | null;
  primaryColor: string | null;
  secondaryColor: string | null;
  players: Player[];
}
