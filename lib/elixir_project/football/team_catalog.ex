defmodule ElixirProject.Football.TeamCatalog do
  @moduledoc """
  Curated catalog of popular top-5 league clubs available to add to the
  dashboard. Logos come from the API-Sports CDN by `api_id`; brand colors theme
  the player HUD. When an API key is configured, the squad is pulled live on add;
  otherwise the team starts empty and players are added via search.
  """

  @teams [
    # Premier League
    %{api_id: 33, name: "Manchester United", league: "Premier League", primary_color: "#DA291C", secondary_color: "#FBE122"},
    %{api_id: 50, name: "Manchester City", league: "Premier League", primary_color: "#6CABDD", secondary_color: "#1C2C5B"},
    %{api_id: 49, name: "Chelsea", league: "Premier League", primary_color: "#034694", secondary_color: "#DBA111"},
    %{api_id: 42, name: "Arsenal", league: "Premier League", primary_color: "#EF0107", secondary_color: "#023474"},
    %{api_id: 47, name: "Tottenham Hotspur", league: "Premier League", primary_color: "#9FC4E8", secondary_color: "#132257"},
    %{api_id: 34, name: "Newcastle United", league: "Premier League", primary_color: "#C4C4C4", secondary_color: "#241F20"},

    # La Liga
    %{api_id: 536, name: "Sevilla", league: "La Liga", primary_color: "#D81E05", secondary_color: "#FFFFFF"},
    %{api_id: 532, name: "Valencia", league: "La Liga", primary_color: "#FF6600", secondary_color: "#231F20"},
    %{api_id: 533, name: "Villarreal", league: "La Liga", primary_color: "#FFCC00", secondary_color: "#004C9B"},
    %{api_id: 548, name: "Real Sociedad", league: "La Liga", primary_color: "#0067B1", secondary_color: "#FFFFFF"},
    %{api_id: 531, name: "Athletic Club", league: "La Liga", primary_color: "#EE2523", secondary_color: "#FFFFFF"},
    %{api_id: 543, name: "Real Betis", league: "La Liga", primary_color: "#00954C", secondary_color: "#FFFFFF"},

    # Serie A
    %{api_id: 496, name: "Juventus", league: "Serie A", primary_color: "#E1E1E1", secondary_color: "#111111"},
    %{api_id: 505, name: "Inter", league: "Serie A", primary_color: "#0068A8", secondary_color: "#111111"},
    %{api_id: 492, name: "Napoli", league: "Serie A", primary_color: "#12A0D7", secondary_color: "#FFFFFF"},
    %{api_id: 497, name: "AS Roma", league: "Serie A", primary_color: "#8E1F2F", secondary_color: "#F0BC42"},
    %{api_id: 487, name: "Lazio", league: "Serie A", primary_color: "#87D8F7", secondary_color: "#0B1560"},
    %{api_id: 499, name: "Atalanta", league: "Serie A", primary_color: "#2581C4", secondary_color: "#111111"},

    # Bundesliga
    %{api_id: 165, name: "Borussia Dortmund", league: "Bundesliga", primary_color: "#FDE100", secondary_color: "#111111"},
    %{api_id: 173, name: "RB Leipzig", league: "Bundesliga", primary_color: "#DD0741", secondary_color: "#001F47"},
    %{api_id: 168, name: "Bayer Leverkusen", league: "Bundesliga", primary_color: "#E32221", secondary_color: "#111111"},
    %{api_id: 169, name: "Eintracht Frankfurt", league: "Bundesliga", primary_color: "#E1000F", secondary_color: "#111111"},
    %{api_id: 163, name: "Borussia Monchengladbach", league: "Bundesliga", primary_color: "#00B04F", secondary_color: "#111111"},
    %{api_id: 172, name: "VfB Stuttgart", league: "Bundesliga", primary_color: "#E32219", secondary_color: "#FFFFFF"},

    # Ligue 1
    %{api_id: 81, name: "Marseille", league: "Ligue 1", primary_color: "#2FAEE0", secondary_color: "#FFFFFF"},
    %{api_id: 91, name: "Monaco", league: "Ligue 1", primary_color: "#E51B22", secondary_color: "#FFFFFF"},
    %{api_id: 80, name: "Lyon", league: "Ligue 1", primary_color: "#DA001A", secondary_color: "#1D3B8B"},
    %{api_id: 79, name: "Lille", league: "Ligue 1", primary_color: "#E01E13", secondary_color: "#1C2C5B"},
    %{api_id: 84, name: "Nice", league: "Ligue 1", primary_color: "#C8102E", secondary_color: "#111111"},
    %{api_id: 116, name: "Lens", league: "Ligue 1", primary_color: "#FFE500", secondary_color: "#E2001A"}
  ]

  @doc "All catalog teams, each with a derived logo URL."
  def all do
    Enum.map(@teams, fn t ->
      Map.put(t, :logo, "https://media.api-sports.io/football/teams/#{t.api_id}.png")
    end)
  end

  @doc "Look up a catalog team by api_id."
  def get(api_id) when is_integer(api_id) do
    Enum.find(all(), &(&1.api_id == api_id))
  end

  def get(api_id) when is_binary(api_id) do
    case Integer.parse(api_id) do
      {id, _} -> get(id)
      :error -> nil
    end
  end
end
