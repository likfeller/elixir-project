defmodule ElixirProject.Repo.Migrations.CreateTeamsAndPlayers do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :api_id, :integer
      add :name, :string, null: false
      add :code, :string
      add :country, :string
      add :logo, :string
      # "club" or "national"
      add :type, :string, default: "club"
      add :league_name, :string
      # Team accent colors used to theme the player HUD
      add :primary_color, :string
      add :secondary_color, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teams, [:api_id])
    create unique_index(:teams, [:name])

    create table(:players) do
      add :api_id, :integer
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :firstname, :string
      add :lastname, :string
      add :number, :integer
      add :position, :string
      add :age, :integer
      add :nationality, :string
      add :photo, :string
      add :season, :integer

      # Analytics stats surfaced on the circuit-trace HUD
      add :appearances, :integer, default: 0
      add :minutes, :integer, default: 0
      add :goals, :integer, default: 0
      add :assists, :integer, default: 0
      add :shots_total, :integer, default: 0
      add :shots_on, :integer, default: 0
      add :passes_total, :integer, default: 0
      add :passes_key, :integer, default: 0
      add :pass_accuracy, :integer, default: 0
      add :dribbles_attempts, :integer, default: 0
      add :dribbles_success, :integer, default: 0
      add :tackles, :integer, default: 0
      add :duels_total, :integer, default: 0
      add :duels_won, :integer, default: 0
      add :rating, :float

      # Full raw stats blob from API-Football, for anything else we want later
      add :raw_stats, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:players, [:team_id])
    create unique_index(:players, [:api_id, :season])
  end
end
