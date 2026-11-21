defmodule Mix.Tasks.Football.Sync do
  @moduledoc """
  Pull real squads, player photos, stats and team crests from API-Football.

      mix football.sync

  Requires an API key (config/dev.secret.exs or API_FOOTBALL_KEY). Uses the
  season from config (:elixir_project, :api_football, :season). Sequential and
  rate-limit aware; the free tier allows 100 requests/day.
  """
  use Mix.Task

  alias ElixirProject.Football
  alias ElixirProject.Football.ApiClient

  @shortdoc "Sync teams/players from API-Football"
  @requirements ["app.start"]

  @impl true
  def run(_args) do
    unless ApiClient.configured?() do
      Mix.raise("""
      No API-Football key configured.
      Add it to config/dev.secret.exs (copy from dev.secret.exs.example)
      or set the API_FOOTBALL_KEY environment variable, then re-run.
      """)
    end

    Football.ensure_seeded()
    Mix.shell().info("Syncing teams from API-Football (season #{ApiClient.season()})...")

    Football.sync_all_from_api()
    |> Enum.each(fn
      {name, {:ok, count}} -> Mix.shell().info("  #{name}: #{count} players updated")
      {name, {:error, reason}} -> Mix.shell().error("  #{name}: #{inspect(reason)}")
    end)

    Mix.shell().info("Done.")
  end
end
