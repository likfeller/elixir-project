# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir_project,
  ecto_repos: [ElixirProject.Repo],
  generators: [timestamp_type: :utc_datetime]

# API-Football (api-sports.io) configuration.
# The key is read from the API_FOOTBALL_KEY env var at runtime (see runtime.exs).
# When no key is present, the app falls back to a built-in sample dataset so the
# dashboard still renders.
config :elixir_project, :api_football,
  base_url: "https://v3.football.api-sports.io",
  key: nil,
  season: 2023

# Configure the endpoint
config :elixir_project, ElixirProjectWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ElixirProjectWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ElixirProject.PubSub,
  live_view: [signing_salt: "S6oOjzkV"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
