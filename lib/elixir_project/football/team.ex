defmodule ElixirProject.Football.Team do
  @moduledoc "A football club or national team we track."
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirProject.Football.Player

  schema "teams" do
    field :api_id, :integer
    field :name, :string
    field :code, :string
    field :country, :string
    field :logo, :string
    field :type, :string, default: "club"
    field :league_name, :string
    field :primary_color, :string
    field :secondary_color, :string

    has_many :players, Player

    timestamps(type: :utc_datetime)
  end

  @fields [
    :api_id,
    :name,
    :code,
    :country,
    :logo,
    :type,
    :league_name,
    :primary_color,
    :secondary_color
  ]

  def changeset(team, attrs) do
    team
    |> cast(attrs, @fields)
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> unique_constraint(:api_id)
  end
end
