defmodule ElixirProjectWeb.Schema do
  @moduledoc "GraphQL schema for the football analytics dashboard."
  use Absinthe.Schema

  alias ElixirProjectWeb.Resolvers.FootballResolver

  @desc "A football club or national team"
  object :team do
    field :id, non_null(:id)
    field :api_id, :integer
    field :name, non_null(:string)
    field :code, :string
    field :country, :string
    field :logo, :string
    field :type, :string
    field :league_name, :string
    field :primary_color, :string
    field :secondary_color, :string

    @desc "Players belonging to this team, ordered by rating"
    field :players, list_of(:player) do
      resolve &FootballResolver.team_players/3
    end
  end

  @desc "A player with season analytics stats"
  object :player do
    field :id, non_null(:id)
    field :api_id, :integer
    field :name, non_null(:string)
    field :firstname, :string
    field :lastname, :string
    field :number, :integer
    field :position, :string
    field :age, :integer
    field :nationality, :string
    field :photo, :string
    field :season, :integer

    field :appearances, :integer
    field :minutes, :integer
    field :goals, :integer
    field :assists, :integer
    field :shots_total, :integer
    field :shots_on, :integer
    field :passes_total, :integer
    field :passes_key, :integer
    field :pass_accuracy, :integer
    field :dribbles_attempts, :integer
    field :dribbles_success, :integer
    field :tackles, :integer
    field :duels_total, :integer
    field :duels_won, :integer
    field :rating, :float
  end

  query do
    @desc "All tracked teams"
    field :teams, list_of(:team) do
      resolve &FootballResolver.list_teams/3
    end

    @desc "A single team by id"
    field :team, :team do
      arg :id, non_null(:id)
      resolve &FootballResolver.get_team/3
    end

    @desc "A single player by id"
    field :player, :player do
      arg :id, non_null(:id)
      resolve &FootballResolver.get_player/3
    end
  end
end
