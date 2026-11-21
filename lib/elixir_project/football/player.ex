defmodule ElixirProject.Football.Player do
  @moduledoc "A player belonging to a tracked team, with season analytics stats."
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirProject.Football.Team

  schema "players" do
    field :api_id, :integer
    field :name, :string
    field :firstname, :string
    field :lastname, :string
    field :number, :integer
    field :position, :string
    field :age, :integer
    field :nationality, :string
    field :photo, :string
    field :season, :integer

    field :appearances, :integer, default: 0
    field :minutes, :integer, default: 0
    field :goals, :integer, default: 0
    field :assists, :integer, default: 0
    field :shots_total, :integer, default: 0
    field :shots_on, :integer, default: 0
    field :passes_total, :integer, default: 0
    field :passes_key, :integer, default: 0
    field :pass_accuracy, :integer, default: 0
    field :dribbles_attempts, :integer, default: 0
    field :dribbles_success, :integer, default: 0
    field :tackles, :integer, default: 0
    field :duels_total, :integer, default: 0
    field :duels_won, :integer, default: 0
    field :rating, :float

    field :raw_stats, :map, default: %{}
    field :description, :string
    field :season_history, :map, default: %{}
    field :history_synced_at, :utc_datetime
    field :favorite, :boolean, default: false

    belongs_to :team, Team

    timestamps(type: :utc_datetime)
  end

  @fields [
    :api_id,
    :team_id,
    :name,
    :firstname,
    :lastname,
    :number,
    :position,
    :age,
    :nationality,
    :photo,
    :season,
    :appearances,
    :minutes,
    :goals,
    :assists,
    :shots_total,
    :shots_on,
    :passes_total,
    :passes_key,
    :pass_accuracy,
    :dribbles_attempts,
    :dribbles_success,
    :tackles,
    :duels_total,
    :duels_won,
    :rating,
    :raw_stats,
    :description,
    :season_history,
    :history_synced_at,
    :favorite
  ]

  def changeset(player, attrs) do
    player
    |> cast(attrs, @fields)
    |> validate_required([:name, :team_id])
  end
end
