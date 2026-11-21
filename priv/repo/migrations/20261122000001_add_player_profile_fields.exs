defmodule ElixirProject.Repo.Migrations.AddPlayerProfileFields do
  use Ecto.Migration

  def change do
    alter table(:players) do
      # Scouting-style description (what type of player, why valued) from Wikipedia.
      add :description, :text
      # Last-N-seasons history (club + international), cached from API-Football.
      # Shape: %{"seasons" => [%{"season" => 2023, "team" => ..., ...}, ...]}
      add :season_history, :map, default: %{}
      # When we last refreshed season_history from the API.
      add :history_synced_at, :utc_datetime
    end
  end
end
