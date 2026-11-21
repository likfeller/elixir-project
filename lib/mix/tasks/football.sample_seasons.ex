defmodule Mix.Tasks.Football.SampleSeasons do
  @moduledoc """
  Populate `players.season_history` with representative last-5-seasons data
  (club + international), derived from each player's current stats. This is a
  placeholder for when a real API-Football key is available — run
  `mix football.sync` later to replace it with live data.

      mix football.sample_seasons
  """
  use Mix.Task
  import Ecto.Query

  alias ElixirProject.Repo
  alias ElixirProject.Football.Player

  @shortdoc "Generate sample last-5-seasons history for players"
  @requirements ["app.start"]
  @years [2019, 2020, 2021, 2022, 2023]

  @impl true
  def run(_args) do
    players = Repo.all(Player) |> Repo.preload(:team)

    count =
      Enum.reduce(players, 0, fn player, acc ->
        history = %{"seasons" => build_seasons(player)}

        {n, _} =
          from(p in Player, where: p.id == ^player.id)
          |> Repo.update_all(set: [season_history: history])

        acc + n
      end)

    Mix.shell().info("Set sample season history for #{count} players.")
  end

  defp build_seasons(player) do
    team = player.team

    club =
      @years
      |> Enum.with_index()
      |> Enum.map(fn {year, i} ->
        # factor ramps 0.55 (oldest) -> 1.0 (current season)
        factor = 0.55 + 0.1125 * i
        j = jitter(player.id, year)
        apps = clamp(round((player.appearances || 20) * factor) + j, 3, 42)

        %{
          "season" => year,
          "team" => team.name,
          "league" => team.league_name,
          "competition_type" => team.type,
          "appearances" => apps,
          "goals" => scale(player.goals, factor, j),
          "assists" => scale(player.assists, factor, j),
          "minutes" => apps * minutes_per_app(player.position),
          "rating" => rating(player.rating, j)
        }
      end)
      |> Enum.reverse()

    club ++ international_rows(player, team)
  end

  # Add a couple of national-team seasons for club players (national-team rows
  # already represent international appearances, so skip those).
  defp international_rows(%{nationality: nil}, _team), do: []

  defp international_rows(player, %{type: "club"} = _team) do
    [2023, 2022]
    |> Enum.map(fn year ->
      j = jitter(player.id, year * 7)
      apps = clamp(6 + rem(abs(j), 6), 2, 14)

      %{
        "season" => year,
        "team" => player.nationality,
        "league" => "International",
        "competition_type" => "national",
        "appearances" => apps,
        "goals" => scale(player.goals, 0.22, j),
        "assists" => scale(player.assists, 0.22, j),
        "minutes" => apps * minutes_per_app(player.position),
        "rating" => rating(player.rating, j - 1)
      }
    end)
  end

  defp international_rows(_player, _team), do: []

  defp minutes_per_app("Goalkeeper"), do: 90
  defp minutes_per_app(_), do: 74

  defp scale(nil, _factor, _j), do: 0
  defp scale(value, factor, j), do: max(0, round(value * factor) + div(j, 2))

  defp rating(nil, j), do: Float.round(6.8 + j * 0.03, 1)
  defp rating(base, j), do: Float.round(base + j * 0.03, 1)

  # deterministic small jitter in -3..3 from a stable hash
  defp jitter(id, salt), do: :erlang.phash2({id, salt}, 7) - 3

  defp clamp(v, lo, hi), do: v |> max(lo) |> min(hi)
end
