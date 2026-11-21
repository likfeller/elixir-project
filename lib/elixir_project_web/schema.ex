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

  @desc "One season of a player's career (club or international)"
  object :season_stat do
    field :season, :integer
    field :team, :string
    field :league, :string
    field :competition_type, :string
    field :appearances, :integer
    field :goals, :integer
    field :assists, :integer
    field :minutes, :integer
    field :rating, :float
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

    field :favorite, :boolean

    @desc "Scouting-style description (what type of player, why valued)"
    field :description, :string

    @desc "Last few seasons of career history (club + international)"
    field :season_history, list_of(:season_stat) do
      resolve &FootballResolver.player_season_history/3
    end
  end

  @desc "A top-5 league team available to add to the dashboard"
  object :catalog_team do
    field :api_id, :integer
    field :name, :string
    field :league, :string
    field :logo, :string
    field :primary_color, :string
    field :secondary_color, :string
  end

  query do
    @desc "All tracked teams"
    field :teams, list_of(:team) do
      resolve &FootballResolver.list_teams/3
    end

    @desc "Top-5 league teams available to add (not already present)"
    field :catalog_teams, list_of(:catalog_team) do
      resolve &FootballResolver.catalog_teams/3
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

  mutation do
    @desc "Add a top-5 league team (by catalog api_id) to the dashboard"
    field :add_team, :team do
      arg :api_id, non_null(:integer)
      resolve &FootballResolver.add_team/3
    end

    @desc "Add a player (by name) to a team"
    field :add_player, :player do
      arg :team_id, non_null(:id)
      arg :name, non_null(:string)
      resolve &FootballResolver.add_player/3
    end

    @desc "Mark/unmark a player as a favorite"
    field :set_favorite, :player do
      arg :id, non_null(:id)
      arg :favorite, non_null(:boolean)
      resolve &FootballResolver.set_favorite/3
    end

    @desc "Remove a player from the dashboard"
    field :remove_player, :boolean do
      arg :id, non_null(:id)
      resolve &FootballResolver.remove_player/3
    end
  end
end
