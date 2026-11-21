defmodule ElixirProject.Football.SampleData do
  @moduledoc """
  Built-in fallback dataset used when no API-Football key is configured, so the
  dashboard always has something to render. Stats are representative of a recent
  season and are not meant to be authoritative.

  Each team map includes accent colors used to theme the circuit-trace HUD, and
  a short list of notable players with analytics stats.
  """

  @season 2023

  def season, do: @season

  @doc "List of team maps, each with a `:players` list."
  def teams do
    [
      %{
        name: "Real Madrid",
        api_id: 541,
        logo: "https://media.api-sports.io/football/teams/541.png",
        code: "RMA",
        country: "Spain",
        type: "club",
        league_name: "La Liga",
        primary_color: "#FEBE10",
        secondary_color: "#00529F",
        players: [
          p("Jude Bellingham", 5, "Midfielder", 20, "England", %{goals: 19, assists: 6, appearances: 28, minutes: 2380, shots_total: 72, shots_on: 38, passes_total: 1340, passes_key: 48, pass_accuracy: 86, dribbles_attempts: 110, dribbles_success: 64, tackles: 41, duels_total: 360, duels_won: 190, rating: 7.9}),
          p("Vinicius Junior", 7, "Attacker", 23, "Brazil", %{goals: 15, assists: 6, appearances: 26, minutes: 2150, shots_total: 95, shots_on: 41, passes_total: 980, passes_key: 55, pass_accuracy: 79, dribbles_attempts: 230, dribbles_success: 120, tackles: 24, duels_total: 410, duels_won: 205, rating: 7.6}),
          p("Rodrygo", 11, "Attacker", 23, "Brazil", %{goals: 14, assists: 9, appearances: 35, minutes: 2700, shots_total: 88, shots_on: 37, passes_total: 1120, passes_key: 60, pass_accuracy: 82, dribbles_attempts: 150, dribbles_success: 78, tackles: 30, duels_total: 300, duels_won: 150, rating: 7.4}),
          p("Luka Modric", 10, "Midfielder", 38, "Croatia", %{goals: 2, assists: 5, appearances: 32, minutes: 1650, shots_total: 28, shots_on: 10, passes_total: 1480, passes_key: 52, pass_accuracy: 90, dribbles_attempts: 60, dribbles_success: 38, tackles: 35, duels_total: 220, duels_won: 110, rating: 7.3}),
          p("Thibaut Courtois", 1, "Goalkeeper", 31, "Belgium", %{goals: 0, assists: 0, appearances: 7, minutes: 630, shots_total: 0, shots_on: 0, passes_total: 240, passes_key: 0, pass_accuracy: 84, dribbles_attempts: 0, dribbles_success: 0, tackles: 1, duels_total: 8, duels_won: 6, rating: 7.1})
        ]
      },
      %{
        name: "Barcelona",
        api_id: 529,
        logo: "https://media.api-sports.io/football/teams/529.png",
        code: "BAR",
        country: "Spain",
        type: "club",
        league_name: "La Liga",
        primary_color: "#A50044",
        secondary_color: "#004D98",
        players: [
          p("Robert Lewandowski", 9, "Attacker", 35, "Poland", %{goals: 19, assists: 9, appearances: 35, minutes: 2900, shots_total: 110, shots_on: 52, passes_total: 820, passes_key: 40, pass_accuracy: 78, dribbles_attempts: 70, dribbles_success: 32, tackles: 12, duels_total: 390, duels_won: 170, rating: 7.4}),
          p("Pedri", 8, "Midfielder", 21, "Spain", %{goals: 4, assists: 3, appearances: 24, minutes: 1700, shots_total: 30, shots_on: 12, passes_total: 1320, passes_key: 38, pass_accuracy: 89, dribbles_attempts: 90, dribbles_success: 58, tackles: 28, duels_total: 210, duels_won: 108, rating: 7.2}),
          p("Gavi", 6, "Midfielder", 19, "Spain", %{goals: 2, assists: 4, appearances: 19, minutes: 1450, shots_total: 22, shots_on: 8, passes_total: 980, passes_key: 30, pass_accuracy: 87, dribbles_attempts: 80, dribbles_success: 44, tackles: 38, duels_total: 260, duels_won: 120, rating: 7.1}),
          p("Raphinha", 11, "Attacker", 27, "Brazil", %{goals: 10, assists: 12, appearances: 33, minutes: 2300, shots_total: 78, shots_on: 30, passes_total: 940, passes_key: 58, pass_accuracy: 80, dribbles_attempts: 160, dribbles_success: 82, tackles: 26, duels_total: 320, duels_won: 150, rating: 7.3}),
          p("Marc-Andre ter Stegen", 1, "Goalkeeper", 31, "Germany", %{goals: 0, assists: 0, appearances: 28, minutes: 2520, shots_total: 0, shots_on: 0, passes_total: 1050, passes_key: 1, pass_accuracy: 83, dribbles_attempts: 0, dribbles_success: 0, tackles: 2, duels_total: 20, duels_won: 14, rating: 7.0})
        ]
      },
      %{
        name: "Atletico Madrid",
        api_id: 530,
        logo: "https://media.api-sports.io/football/teams/530.png",
        code: "ATM",
        country: "Spain",
        type: "club",
        league_name: "La Liga",
        primary_color: "#CB3524",
        secondary_color: "#262E62",
        players: [
          p("Antoine Griezmann", 7, "Attacker", 32, "France", %{goals: 16, assists: 7, appearances: 34, minutes: 2850, shots_total: 96, shots_on: 44, passes_total: 1180, passes_key: 70, pass_accuracy: 83, dribbles_attempts: 100, dribbles_success: 55, tackles: 40, duels_total: 360, duels_won: 170, rating: 7.6}),
          p("Alvaro Morata", 19, "Attacker", 31, "Spain", %{goals: 15, assists: 3, appearances: 32, minutes: 2100, shots_total: 85, shots_on: 42, passes_total: 620, passes_key: 24, pass_accuracy: 76, dribbles_attempts: 55, dribbles_success: 26, tackles: 14, duels_total: 340, duels_won: 150, rating: 7.2}),
          p("Jan Oblak", 13, "Goalkeeper", 31, "Slovenia", %{goals: 0, assists: 0, appearances: 33, minutes: 2970, shots_total: 0, shots_on: 0, passes_total: 880, passes_key: 0, pass_accuracy: 72, dribbles_attempts: 0, dribbles_success: 0, tackles: 1, duels_total: 16, duels_won: 11, rating: 7.0}),
          p("Koke", 6, "Midfielder", 32, "Spain", %{goals: 1, assists: 6, appearances: 30, minutes: 2200, shots_total: 20, shots_on: 6, passes_total: 1560, passes_key: 44, pass_accuracy: 88, dribbles_attempts: 40, dribbles_success: 22, tackles: 44, duels_total: 240, duels_won: 118, rating: 7.1}),
          p("Rodrigo De Paul", 5, "Midfielder", 29, "Argentina", %{goals: 3, assists: 5, appearances: 31, minutes: 2400, shots_total: 36, shots_on: 12, passes_total: 1420, passes_key: 42, pass_accuracy: 85, dribbles_attempts: 70, dribbles_success: 38, tackles: 60, duels_total: 300, duels_won: 140, rating: 7.2})
        ]
      },
      %{
        name: "Paris Saint Germain",
        api_id: 85,
        logo: "https://media.api-sports.io/football/teams/85.png",
        code: "PSG",
        country: "France",
        type: "club",
        league_name: "Ligue 1",
        primary_color: "#004170",
        secondary_color: "#DA291C",
        players: [
          p("Kylian Mbappe", 7, "Attacker", 25, "France", %{goals: 27, assists: 7, appearances: 29, minutes: 2400, shots_total: 130, shots_on: 68, passes_total: 920, passes_key: 60, pass_accuracy: 80, dribbles_attempts: 200, dribbles_success: 110, tackles: 18, duels_total: 380, duels_won: 190, rating: 8.0}),
          p("Ousmane Dembele", 10, "Attacker", 26, "France", %{goals: 4, assists: 8, appearances: 30, minutes: 2150, shots_total: 60, shots_on: 22, passes_total: 980, passes_key: 65, pass_accuracy: 79, dribbles_attempts: 190, dribbles_success: 95, tackles: 24, duels_total: 300, duels_won: 140, rating: 7.3}),
          p("Achraf Hakimi", 2, "Defender", 25, "Morocco", %{goals: 4, assists: 6, appearances: 33, minutes: 2800, shots_total: 40, shots_on: 16, passes_total: 1680, passes_key: 44, pass_accuracy: 84, dribbles_attempts: 110, dribbles_success: 60, tackles: 70, duels_total: 360, duels_won: 180, rating: 7.4}),
          p("Vitinha", 17, "Midfielder", 24, "Portugal", %{goals: 3, assists: 4, appearances: 32, minutes: 2500, shots_total: 44, shots_on: 16, passes_total: 2100, passes_key: 50, pass_accuracy: 90, dribbles_attempts: 90, dribbles_success: 56, tackles: 55, duels_total: 280, duels_won: 140, rating: 7.3}),
          p("Gianluigi Donnarumma", 1, "Goalkeeper", 25, "Italy", %{goals: 0, assists: 0, appearances: 29, minutes: 2610, shots_total: 0, shots_on: 0, passes_total: 940, passes_key: 0, pass_accuracy: 82, dribbles_attempts: 0, dribbles_success: 0, tackles: 1, duels_total: 12, duels_won: 9, rating: 7.1})
        ]
      },
      %{
        name: "Bayern Munich",
        api_id: 157,
        logo: "https://media.api-sports.io/football/teams/157.png",
        code: "BAY",
        country: "Germany",
        type: "club",
        league_name: "Bundesliga",
        primary_color: "#DC052D",
        secondary_color: "#0066B2",
        players: [
          p("Harry Kane", 9, "Attacker", 30, "England", %{goals: 36, assists: 8, appearances: 32, minutes: 2850, shots_total: 140, shots_on: 72, passes_total: 980, passes_key: 66, pass_accuracy: 80, dribbles_attempts: 60, dribbles_success: 30, tackles: 16, duels_total: 400, duels_won: 180, rating: 8.1}),
          p("Jamal Musiala", 42, "Midfielder", 21, "Germany", %{goals: 10, assists: 6, appearances: 29, minutes: 2200, shots_total: 70, shots_on: 30, passes_total: 1080, passes_key: 52, pass_accuracy: 85, dribbles_attempts: 210, dribbles_success: 120, tackles: 30, duels_total: 320, duels_won: 160, rating: 7.5}),
          p("Leroy Sane", 10, "Attacker", 28, "Germany", %{goals: 8, assists: 11, appearances: 31, minutes: 2400, shots_total: 82, shots_on: 34, passes_total: 1040, passes_key: 58, pass_accuracy: 82, dribbles_attempts: 170, dribbles_success: 88, tackles: 22, duels_total: 300, duels_won: 140, rating: 7.4}),
          p("Joshua Kimmich", 6, "Midfielder", 29, "Germany", %{goals: 2, assists: 10, appearances: 33, minutes: 2900, shots_total: 40, shots_on: 12, passes_total: 2400, passes_key: 70, pass_accuracy: 89, dribbles_attempts: 60, dribbles_success: 34, tackles: 75, duels_total: 340, duels_won: 170, rating: 7.4}),
          p("Manuel Neuer", 1, "Goalkeeper", 38, "Germany", %{goals: 0, assists: 0, appearances: 25, minutes: 2250, shots_total: 0, shots_on: 0, passes_total: 900, passes_key: 0, pass_accuracy: 85, dribbles_attempts: 0, dribbles_success: 0, tackles: 2, duels_total: 14, duels_won: 10, rating: 7.1})
        ]
      },
      %{
        name: "AC Milan",
        api_id: 489,
        logo: "https://media.api-sports.io/football/teams/489.png",
        code: "MIL",
        country: "Italy",
        type: "club",
        league_name: "Serie A",
        primary_color: "#FB090B",
        secondary_color: "#FFFFFF",
        players: [
          p("Rafael Leao", 10, "Attacker", 24, "Portugal", %{goals: 9, assists: 10, appearances: 34, minutes: 2800, shots_total: 92, shots_on: 34, passes_total: 1060, passes_key: 56, pass_accuracy: 80, dribbles_attempts: 240, dribbles_success: 118, tackles: 26, duels_total: 360, duels_won: 170, rating: 7.4}),
          p("Olivier Giroud", 9, "Attacker", 37, "France", %{goals: 15, assists: 5, appearances: 33, minutes: 2500, shots_total: 88, shots_on: 42, passes_total: 760, passes_key: 34, pass_accuracy: 78, dribbles_attempts: 40, dribbles_success: 18, tackles: 12, duels_total: 380, duels_won: 170, rating: 7.2}),
          p("Christian Pulisic", 11, "Attacker", 25, "USA", %{goals: 12, assists: 8, appearances: 35, minutes: 2700, shots_total: 86, shots_on: 36, passes_total: 1040, passes_key: 62, pass_accuracy: 81, dribbles_attempts: 150, dribbles_success: 78, tackles: 34, duels_total: 300, duels_won: 150, rating: 7.4}),
          p("Theo Hernandez", 19, "Defender", 26, "France", %{goals: 4, assists: 4, appearances: 34, minutes: 2950, shots_total: 50, shots_on: 18, passes_total: 1720, passes_key: 40, pass_accuracy: 84, dribbles_attempts: 130, dribbles_success: 70, tackles: 66, duels_total: 360, duels_won: 180, rating: 7.3}),
          p("Mike Maignan", 16, "Goalkeeper", 28, "France", %{goals: 0, assists: 1, appearances: 33, minutes: 2970, shots_total: 0, shots_on: 0, passes_total: 1020, passes_key: 2, pass_accuracy: 80, dribbles_attempts: 0, dribbles_success: 0, tackles: 2, duels_total: 18, duels_won: 13, rating: 7.1})
        ]
      },
      %{
        name: "Liverpool",
        api_id: 40,
        logo: "https://media.api-sports.io/football/teams/40.png",
        code: "LIV",
        country: "England",
        type: "club",
        league_name: "Premier League",
        primary_color: "#C8102E",
        secondary_color: "#00B2A9",
        players: [
          p("Mohamed Salah", 11, "Attacker", 31, "Egypt", %{goals: 18, assists: 10, appearances: 32, minutes: 2650, shots_total: 120, shots_on: 56, passes_total: 980, passes_key: 64, pass_accuracy: 80, dribbles_attempts: 150, dribbles_success: 78, tackles: 18, duels_total: 340, duels_won: 160, rating: 7.7}),
          p("Darwin Nunez", 9, "Attacker", 24, "Uruguay", %{goals: 11, assists: 8, appearances: 36, minutes: 2300, shots_total: 125, shots_on: 50, passes_total: 640, passes_key: 40, pass_accuracy: 74, dribbles_attempts: 120, dribbles_success: 56, tackles: 20, duels_total: 400, duels_won: 180, rating: 7.2}),
          p("Luis Diaz", 7, "Attacker", 27, "Colombia", %{goals: 13, assists: 5, appearances: 35, minutes: 2500, shots_total: 90, shots_on: 38, passes_total: 920, passes_key: 46, pass_accuracy: 81, dribbles_attempts: 200, dribbles_success: 100, tackles: 30, duels_total: 340, duels_won: 160, rating: 7.4}),
          p("Dominik Szoboszlai", 8, "Midfielder", 23, "Hungary", %{goals: 3, assists: 4, appearances: 32, minutes: 2300, shots_total: 70, shots_on: 24, passes_total: 1380, passes_key: 54, pass_accuracy: 85, dribbles_attempts: 90, dribbles_success: 48, tackles: 55, duels_total: 300, duels_won: 150, rating: 7.2}),
          p("Alisson", 1, "Goalkeeper", 31, "Brazil", %{goals: 0, assists: 1, appearances: 28, minutes: 2520, shots_total: 0, shots_on: 0, passes_total: 980, passes_key: 2, pass_accuracy: 83, dribbles_attempts: 0, dribbles_success: 0, tackles: 1, duels_total: 12, duels_won: 9, rating: 7.2})
        ]
      },
      %{
        name: "Brazil",
        # api_id resolved from API by name on sync (keeps flag as badge until then)
        api_id: nil,
        logo: "https://flagcdn.com/w320/br.png",
        code: "BRA",
        country: "Brazil",
        type: "national",
        league_name: "National Team",
        primary_color: "#FFDF00",
        secondary_color: "#009739",
        players: [
          p("Rodrygo", 10, "Attacker", 23, "Brazil", %{goals: 5, assists: 4, appearances: 14, minutes: 1100, shots_total: 32, shots_on: 14, passes_total: 420, passes_key: 20, pass_accuracy: 83, dribbles_attempts: 60, dribbles_success: 32, tackles: 10, duels_total: 120, duels_won: 60, rating: 7.3}),
          p("Vinicius Junior", 7, "Attacker", 23, "Brazil", %{goals: 3, assists: 4, appearances: 12, minutes: 980, shots_total: 36, shots_on: 15, passes_total: 360, passes_key: 22, pass_accuracy: 79, dribbles_attempts: 90, dribbles_success: 46, tackles: 8, duels_total: 150, duels_won: 72, rating: 7.4}),
          p("Casemiro", 5, "Midfielder", 32, "Brazil", %{goals: 2, assists: 1, appearances: 13, minutes: 1120, shots_total: 18, shots_on: 6, passes_total: 720, passes_key: 12, pass_accuracy: 88, dribbles_attempts: 20, dribbles_success: 10, tackles: 48, duels_total: 160, duels_won: 90, rating: 7.1}),
          p("Marquinhos", 4, "Defender", 29, "Brazil", %{goals: 1, assists: 0, appearances: 15, minutes: 1350, shots_total: 10, shots_on: 4, passes_total: 980, passes_key: 6, pass_accuracy: 91, dribbles_attempts: 8, dribbles_success: 5, tackles: 36, duels_total: 120, duels_won: 80, rating: 7.1}),
          p("Alisson", 1, "Goalkeeper", 31, "Brazil", %{goals: 0, assists: 0, appearances: 12, minutes: 1080, shots_total: 0, shots_on: 0, passes_total: 420, passes_key: 0, pass_accuracy: 84, dribbles_attempts: 0, dribbles_success: 0, tackles: 0, duels_total: 6, duels_won: 4, rating: 7.1})
        ]
      },
      %{
        name: "Poland",
        api_id: nil,
        logo: "https://flagcdn.com/w320/pl.png",
        code: "POL",
        country: "Poland",
        type: "national",
        league_name: "National Team",
        primary_color: "#DC143C",
        secondary_color: "#FFFFFF",
        players: [
          p("Robert Lewandowski", 9, "Attacker", 35, "Poland", %{goals: 6, assists: 2, appearances: 12, minutes: 1020, shots_total: 44, shots_on: 20, passes_total: 320, passes_key: 14, pass_accuracy: 76, dribbles_attempts: 24, dribbles_success: 10, tackles: 4, duels_total: 140, duels_won: 60, rating: 7.2}),
          p("Piotr Zielinski", 20, "Midfielder", 30, "Poland", %{goals: 3, assists: 4, appearances: 13, minutes: 1100, shots_total: 28, shots_on: 10, passes_total: 680, passes_key: 24, pass_accuracy: 86, dribbles_attempts: 40, dribbles_success: 22, tackles: 22, duels_total: 120, duels_won: 60, rating: 7.1}),
          p("Nicola Zalewski", 21, "Defender", 22, "Poland", %{goals: 1, assists: 3, appearances: 11, minutes: 900, shots_total: 16, shots_on: 6, passes_total: 520, passes_key: 18, pass_accuracy: 82, dribbles_attempts: 50, dribbles_success: 26, tackles: 28, duels_total: 130, duels_won: 62, rating: 7.0}),
          p("Jakub Kiwior", 15, "Defender", 24, "Poland", %{goals: 0, assists: 1, appearances: 12, minutes: 1050, shots_total: 8, shots_on: 2, passes_total: 740, passes_key: 6, pass_accuracy: 89, dribbles_attempts: 10, dribbles_success: 6, tackles: 30, duels_total: 100, duels_won: 60, rating: 7.0}),
          p("Wojciech Szczesny", 1, "Goalkeeper", 34, "Poland", %{goals: 0, assists: 0, appearances: 11, minutes: 990, shots_total: 0, shots_on: 0, passes_total: 360, passes_key: 0, pass_accuracy: 78, dribbles_attempts: 0, dribbles_success: 0, tackles: 0, duels_total: 6, duels_won: 4, rating: 7.0})
        ]
      },
      %{
        name: "Albania",
        api_id: nil,
        logo: "https://flagcdn.com/w320/al.png",
        code: "ALB",
        country: "Albania",
        type: "national",
        league_name: "National Team",
        primary_color: "#E41E20",
        secondary_color: "#B8860B",
        players: [
          p("Armando Broja", 18, "Attacker", 22, "Albania", %{goals: 4, assists: 2, appearances: 12, minutes: 820, shots_total: 30, shots_on: 12, passes_total: 220, passes_key: 10, pass_accuracy: 72, dribbles_attempts: 40, dribbles_success: 18, tackles: 6, duels_total: 130, duels_won: 55, rating: 6.9}),
          p("Kristjan Asllani", 8, "Midfielder", 22, "Albania", %{goals: 2, assists: 3, appearances: 13, minutes: 1000, shots_total: 24, shots_on: 8, passes_total: 760, passes_key: 20, pass_accuracy: 87, dribbles_attempts: 30, dribbles_success: 16, tackles: 26, duels_total: 110, duels_won: 52, rating: 7.0}),
          p("Nedim Bajrami", 10, "Midfielder", 25, "Albania", %{goals: 3, assists: 2, appearances: 12, minutes: 880, shots_total: 26, shots_on: 10, passes_total: 420, passes_key: 18, pass_accuracy: 81, dribbles_attempts: 44, dribbles_success: 22, tackles: 18, duels_total: 120, duels_won: 56, rating: 6.9}),
          p("Berat Djimsiti", 15, "Defender", 31, "Albania", %{goals: 1, assists: 0, appearances: 14, minutes: 1260, shots_total: 10, shots_on: 4, passes_total: 820, passes_key: 4, pass_accuracy: 88, dribbles_attempts: 8, dribbles_success: 5, tackles: 34, duels_total: 130, duels_won: 80, rating: 7.1}),
          p("Thomas Strakosha", 1, "Goalkeeper", 29, "Albania", %{goals: 0, assists: 0, appearances: 10, minutes: 900, shots_total: 0, shots_on: 0, passes_total: 300, passes_key: 0, pass_accuracy: 74, dribbles_attempts: 0, dribbles_success: 0, tackles: 0, duels_total: 4, duels_won: 3, rating: 6.9})
        ]
      }
    ]
  end

  # Build a player map with sensible defaults merged with the given stats.
  defp p(name, number, position, age, nationality, stats) do
    Map.merge(
      %{
        name: name,
        number: number,
        position: position,
        age: age,
        nationality: nationality,
        season: @season,
        photo: nil
      },
      stats
    )
  end
end
