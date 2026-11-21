export interface Player {
  id: string;
  name: string;
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
