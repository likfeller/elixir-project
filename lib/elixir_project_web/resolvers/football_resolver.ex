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

  # Field resolver for team.players (uses the preloaded/queried association).
  def team_players(team, _args, _res) do
    {:ok, Football.list_players_for_team(team.id)}
  end
end
