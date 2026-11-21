defmodule ElixirProjectWeb.Resolvers.FootballResolver do
  @moduledoc "GraphQL resolvers for teams and players."

  alias ElixirProject.Football

  def list_teams(_parent, _args, _res) do
    {:ok, Football.list_teams()}
  end

  def get_team(_parent, %{id: id}, _res) do
    case Football.get_team(id) do
      nil -> {:error, "Team #{id} not found"}
      team -> {:ok, team}
    end
  end

  def get_player(_parent, %{id: id}, _res) do
    case Football.get_player(id) do
      nil -> {:error, "Player #{id} not found"}
      player -> {:ok, player}
    end
  end

  def catalog_teams(_parent, _args, _res) do
    {:ok, Football.catalog_teams()}
  end

  def add_team(_parent, %{api_id: api_id}, _res) do
    case Football.add_team_from_catalog(api_id) do
      {:ok, team} -> {:ok, team}
      {:error, reason} -> {:error, "Could not add team: #{inspect(reason)}"}
    end
  end

  def add_player(_parent, %{team_id: team_id, name: name}, _res) do
    case Football.add_player_by_name(team_id, name) do
      {:ok, player} -> {:ok, player}
      {:error, reason} -> {:error, "Could not add player: #{inspect(reason)}"}
    end
  end

  # Field resolver for team.players (uses the preloaded/queried association).
  def team_players(team, _args, _res) do
    {:ok, Football.list_players_for_team(team.id)}
  end

  # Field resolver for player.season_history — reads the cached jsonb and
  # normalizes each season into atom-keyed maps for Absinthe.
  def player_season_history(player, _args, _res) do
    seasons =
      case player.season_history do
        %{"seasons" => list} when is_list(list) -> list
        _ -> []
      end

    {:ok, Enum.map(seasons, &normalize_season/1)}
  end

  defp normalize_season(s) do
    %{
      season: s["season"],
      team: s["team"],
      league: s["league"],
      competition_type: s["competition_type"],
      appearances: s["appearances"],
      goals: s["goals"],
      assists: s["assists"],
      minutes: s["minutes"],
      rating: s["rating"]
    }
  end
end
