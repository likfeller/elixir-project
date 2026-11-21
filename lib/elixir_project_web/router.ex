defmodule ElixirProjectWeb.Router do
  use ElixirProjectWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
  end

  # GraphQL API
  scope "/api" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: ElixirProjectWeb.Schema
  end

  # Interactive GraphQL explorer (dev only)
  if Application.compile_env(:elixir_project, :dev_routes) do
    scope "/" do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: ElixirProjectWeb.Schema,
        interface: :playground
    end
  end

  # Serve the React single-page app for everything else (client-side routing).
  scope "/", ElixirProjectWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end
