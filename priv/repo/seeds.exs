# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirProject.Repo.insert!(%ElixirProject.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Seed the tracked teams and their players from the built-in sample dataset.
# (No-op if teams already exist.)
{:ok, count} = ElixirProject.Football.ensure_seeded()
IO.puts("Teams in database: #{count}")
