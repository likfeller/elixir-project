defmodule ElixirProject.Football do
  @moduledoc """
  Context for teams and players: database queries plus seeding/syncing from
  either the built-in sample dataset or the live API-Football service.
  """
  import Ecto.Query, warn: false

  alias ElixirProject.Repo
  alias ElixirProject.Football.{Team, Player, ApiClient, SampleData}

  # --- queries ---

  def list_teams do
    Repo.all(from t in Team, order_by: [asc: t.type, asc: t.name])
  end

  def get_team!(id), do: Repo.get!(Team, id)
  def get_team(id), do: Repo.get(Team, id)

  def get_team_by_name(name), do: Repo.get_by(Team, name: name)

  def list_players_for_team(team_id) do
    Repo.all(
      from p in Player,
        where: p.team_id == ^team_id,
        order_by: [desc: p.rating, desc: p.goals]
    )
  end

  def get_player!(id), do: Repo.get!(Player, id)
  def get_player(id), do: Repo.get(Player, id)

  def count_teams, do: Repo.aggregate(Team, :count)

  # --- seeding ---

  @doc """
  Ensure the database has data. Seeds from the built-in sample dataset when
  empty. Safe to call repeatedly (no-op when teams already exist).
  """
  def ensure_seeded do
    if count_teams() == 0 do
      seed_from_sample()
    else
      {:ok, :already_seeded}
    end
  end

  @doc "Insert all sample teams and their players."
  def seed_from_sample do
    Enum.each(SampleData.teams(), fn team_attrs ->
      {players, team_only} = Map.pop(team_attrs, :players)

      {:ok, team} =
        %Team{}
        |> Team.changeset(team_only)
        |> Repo.insert(on_conflict: :nothing)

      team = team || get_team_by_name(team_only.name)

      Enum.each(players || [], fn player_attrs ->
        %Player{}
        |> Player.changeset(Map.put(player_attrs, :team_id, team.id))
        |> Repo.insert(on_conflict: :nothing)
      end)
    end)

    {:ok, count_teams()}
  end

  # --- live sync from API-Football ---

  @doc """
  Refresh a team's players from API-Football. Requires a configured API key.
  Resolves the team's api_id by name if not already stored, then pulls season
  player statistics and upserts them.
  """
  def sync_team_from_api(%Team{} = team) do
    if ApiClient.configured?() do
      with {:ok, team} <- ensure_api_id(team),
           {:ok, players} <- ApiClient.player_stats(team.api_id, ApiClient.season()) do
        count = upsert_api_players(team, players)
        {:ok, count}
      end
    else
      {:error, :no_api_key}
    end
  end

  defp ensure_api_id(%Team{api_id: nil} = team) do
    with {:ok, %{"team" => %{"id" => api_id} = api_team}} <- ApiClient.search_team(team.name) do
      team
      |> Team.changeset(%{api_id: api_id, logo: api_team["logo"] || team.logo})
      |> Repo.update()
    end
  end

  defp ensure_api_id(%Team{} = team), do: {:ok, team}

  @doc "Refresh every tracked team from API-Football (sequential, rate-limit aware)."
  def sync_all_from_api do
    Enum.map(list_teams(), fn team ->
      result = sync_team_from_api(team)
      # Stay under the per-minute free-tier limit between teams.
      Process.sleep(500)
      {team.name, result}
    end)
  end

  defp upsert_api_players(team, players) do
    Enum.reduce(players, 0, fn entry, acc ->
      attrs = map_api_player(team, entry)

      case Repo.get_by(Player, api_id: attrs.api_id, season: attrs.season) do
        nil -> %Player{}
        existing -> existing
      end
      |> Player.changeset(attrs)
      |> Repo.insert_or_update()
      |> case do
        {:ok, _} -> acc + 1
        {:error, _} -> acc
      end
    end)
  end

  # Map one API-Football /players entry to our Player attrs.
  defp map_api_player(team, %{"player" => player, "statistics" => stats}) do
    s = List.first(stats) || %{}
    games = s["games"] || %{}
    shots = s["shots"] || %{}
    goals = s["goals"] || %{}
    passes = s["passes"] || %{}
    dribbles = s["dribbles"] || %{}
    tackles = s["tackles"] || %{}
    duels = s["duels"] || %{}

    %{
      api_id: player["id"],
      team_id: team.id,
      name: player["name"],
      firstname: player["firstname"],
      lastname: player["lastname"],
      age: player["age"],
      nationality: player["nationality"],
      photo: player["photo"],
      number: games["number"],
      position: games["position"],
      season: ApiClient.season(),
      appearances: int(games["appearences"]),
      minutes: int(games["minutes"]),
      goals: int(goals["total"]),
      assists: int(goals["assists"]),
      shots_total: int(shots["total"]),
      shots_on: int(shots["on"]),
      passes_total: int(passes["total"]),
      passes_key: int(passes["key"]),
      pass_accuracy: int(passes["accuracy"]),
      dribbles_attempts: int(dribbles["attempts"]),
      dribbles_success: int(dribbles["success"]),
      tackles: int(tackles["total"]),
      duels_total: int(duels["total"]),
      duels_won: int(duels["won"]),
      rating: float(games["rating"]),
      raw_stats: s
    }
  end

  defp int(nil), do: 0
  defp int(n) when is_integer(n), do: n
  defp int(n) when is_binary(n), do: String.to_integer(String.replace(n, "%", ""))
  defp int(_), do: 0

  defp float(nil), do: nil
  defp float(n) when is_float(n), do: n
  defp float(n) when is_integer(n), do: n * 1.0

  defp float(n) when is_binary(n) do
    case Float.parse(n) do
      {f, _} -> f
      :error -> nil
    end
  end
end
