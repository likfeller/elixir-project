defmodule ElixirProject.Repo.Migrations.AddPlayerFavorite do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :favorite, :boolean, default: false, null: false
    end

    create index(:players, [:favorite])
  end
end
