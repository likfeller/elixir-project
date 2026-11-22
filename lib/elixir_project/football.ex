defmodule ElixirProject.Football do
  @moduledoc """
  Context for teams and players: database queries plus seeding/syncing from
  either the built-in sample dataset or the live API-Football service.
  """
  import Ecto.Query, warn: false

  alias ElixirProject.Repo
  alias ElixirProject.Football.{Team, Player, ApiClient, SampleData, TeamCatalog, Wikipedia}

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

  @max_favorites 11

  def max_favorites, do: @max_favorites

  def list_favorites do
    Repo.all(from p in Player, where: p.favorite == true, order_by: [desc: p.rating])
  end

  def count_favorites do
    Repo.aggregate(from(p in Player, where: p.favorite == true), :count)
  end

  def set_favorite(id, favorite) when is_boolean(favorite) do
    case Repo.get(Player, id) do
      nil ->
        {:error, :not_found}

      player ->
        cond do
          favorite and not player.favorite and count_favorites() >= @max_favorites ->
            {:error, :max_favorites}

          true ->
            player |> Player.changeset(%{favorite: favorite}) |> Repo.update()
        end
    end
  end

  def remove_player(id) do
    case Repo.get(Player, id) do
      nil -> {:error, :not_found}
      player -> Repo.delete(player)
    end
  end

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

  # --- adding teams & players ---

  @sample_years [2019, 2020, 2021, 2022, 2023]

  @doc "Catalog teams available to add (top-5 leagues, minus ones already present)."
  def catalog_teams do
    existing_ids = Repo.all(from t in Team, select: t.api_id) |> MapSet.new()
    existing_names = Repo.all(from t in Team, select: t.name) |> MapSet.new()

    TeamCatalog.all()
    |> Enum.reject(fn t ->
      MapSet.member?(existing_ids, t.api_id) or MapSet.member?(existing_names, t.name)
    end)
  end

  @doc """
  Add a team from the catalog. When an API key is configured, its real squad is
  pulled immediately; otherwise it starts empty and players are added by search.
  """
  def add_team_from_catalog(api_id) do
    case TeamCatalog.get(api_id) do
      nil ->
        {:error, :not_in_catalog}

      cat ->
        attrs = %{
          api_id: cat.api_id,
          name: cat.name,
          league_name: cat.league,
          type: "club",
          logo: cat.logo,
          primary_color: cat.primary_color,
          secondary_color: cat.secondary_color
        }

        case %Team{} |> Team.changeset(attrs) |> Repo.insert() do
          {:ok, team} ->
            if ApiClient.configured?(), do: sync_team_from_api(team)
            {:ok, team}

          {:error, _} = err ->
            case get_team_by_name(cat.name) do
              nil -> err
              existing -> {:ok, existing}
            end
        end
    end
  end

  @doc """
  Add a player (by name) to a team. With an API key we fetch real stats/photo
  from API-Football; otherwise we pull a photo + description from Wikipedia and
  generate representative stats.
  """
  def add_player_by_name(team_id, name) do
    team = get_team!(team_id)
    name = String.trim(name)

    cond do
      name == "" -> {:error, :empty_name}
      ApiClient.configured?() -> add_player_via_api(team, name)
      true -> add_player_via_wiki(team, name)
    end
  end

  defp add_player_via_api(team, name) do
    with {:ok, team} <- ensure_api_id(team),
         {:ok, %{"response" => [entry | _]}} <-
           ApiClient.search_player_in_team(team.api_id, ApiClient.season(), name) do
      attrs =
        team
        |> map_api_player(entry)
        |> put_sample_seasons(team)

      %Player{} |> Player.changeset(attrs) |> Repo.insert()
    else
      _ -> add_player_via_wiki(team, name)
    end
  end

  defp add_player_via_wiki(team, name) do
    wiki = Wikipedia.lookup(name) || %{photo: nil, description: nil}

    attrs =
      team
      |> sample_player_attrs(name)
      |> Map.put(:photo, wiki.photo)
      |> Map.put(:description, wiki.description)
      |> put_sample_seasons(team)

    %Player{} |> Player.changeset(attrs) |> Repo.insert()
  end

  # Representative current-season stats for a newly added player, derived
  # deterministically from the name so repeats are stable.
  defp sample_player_attrs(team, name) do
    h = :erlang.phash2(name, 1000)
    apps = 18 + rem(h, 20)
    goals = rem(h, 14)
    assists = rem(div(h, 3), 10)

    %{
      name: name,
      team_id: team.id,
      season: 2023,
      appearances: apps,
      minutes: apps * 74,
      goals: goals,
      assists: assists,
      shots_total: goals * 4 + rem(h, 20),
      shots_on: goals * 2 + rem(h, 8),
      passes_total: apps * 35,
      passes_key: rem(h, 40),
      pass_accuracy: 74 + rem(h, 18),
      dribbles_attempts: rem(h, 120),
      dribbles_success: rem(div(h, 2), 70),
      tackles: rem(div(h, 5), 60),
      duels_total: 100 + rem(h, 250),
      duels_won: 50 + rem(h, 120),
      rating: Float.round(6.7 + rem(h, 13) / 10, 1)
    }
  end

  defp put_sample_seasons(attrs, team) do
    name = attrs[:name] || attrs["name"]
    apps = attrs[:appearances] || 20
    goals = attrs[:goals] || 0
    assists = attrs[:assists] || 0
    rating = attrs[:rating] || 6.9

    seasons =
      @sample_years
      |> Enum.with_index()
      |> Enum.map(fn {year, i} ->
        f = 0.55 + 0.1125 * i
        j = :erlang.phash2({name, year}, 7) - 3
        a = (round(apps * f) + j) |> max(3) |> min(42)

        %{
          "season" => year,
          "team" => team.name,
          "league" => team.league_name,
          "competition_type" => team.type,
          "appearances" => a,
          "goals" => max(0, round(goals * f) + div(j, 2)),
          "assists" => max(0, round(assists * f) + div(j, 2)),
          "minutes" => a * 74,
          "rating" => Float.round(rating + j * 0.03, 1)
        }
      end)
      |> Enum.reverse()

    Map.put(attrs, :season_history, %{"seasons" => seasons})
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
