defmodule ElixirProject.Repo.Migrations.PlayersPhotoToText do
  use Ecto.Migration

  def change do
    # Wikipedia/CDN image URLs can exceed 255 chars.
    alter table(:players) do
      modify :photo, :text, from: :string
    end
  end
end
