defmodule ElixirProject.Football.ApiClient do
  @moduledoc """
  Thin client for API-Football (api-sports.io, v3).

  Auth is via the `x-apisports-key` header. All requests are no-ops returning
  `{:error, :no_api_key}` when no key is configured, so callers can fall back to
  the built-in sample dataset.

  Free tier: 100 requests/day, 10 requests/minute — be sparing and cache results
  in the database (see `ElixirProject.Football.sync_*`).
  """
  require Logger

  @doc "Whether an API key is configured."
  def configured?, do: not is_nil(key())

  @doc """
  Resolve a team by name, e.g. "Real Madrid" or "Brazil".
  Returns `{:ok, team_map}` using the first search hit.
  """
  def search_team(name) do
    with {:ok, %{"response" => [first | _]}} <- get("/teams", search: name) do
      {:ok, first}
    else
      {:ok, %{"response" => []}} -> {:error, :not_found}
      other -> normalize_error(other)
    end
  end

  @doc "Fetch a team's current squad (list of player maps)."
  def squad(team_api_id) do
    with {:ok, %{"response" => [%{"players" => players} | _]}} <-
           get("/players/squads", team: team_api_id) do
      {:ok, players}
    else
      other -> normalize_error(other)
    end
  end

  @doc """
  Fetch players with season statistics for a team. Handles pagination and
  returns the flattened list of `%{"player" => ..., "statistics" => [...]}`.
  """
  def player_stats(team_api_id, season) do
    fetch_pages(team_api_id, season, 1, [])
  end

  defp fetch_pages(team_api_id, season, page, acc) do
    case get("/players", team: team_api_id, season: season, page: page) do
      {:ok, %{"response" => response, "paging" => %{"current" => cur, "total" => total}}} ->
        acc = acc ++ response

        if cur < total do
          # Stay under the per-minute rate limit between pages.
          Process.sleep(300)
          fetch_pages(team_api_id, season, page + 1, acc)
        else
          {:ok, acc}
        end

      other ->
        normalize_error(other)
    end
  end

  @doc "Search for a player on a given team/season by (partial) name."
  def search_player_in_team(team_api_id, season, name) do
    get("/players", team: team_api_id, season: season, search: name)
  end

  # --- low level ---

  defp get(path, params) do
    case key() do
      nil ->
        {:error, :no_api_key}

      api_key ->
        url = base_url() <> path

        case Req.get(url, params: params, headers: [{"x-apisports-key", api_key}], retry: false) do
          {:ok, %Req.Response{status: 200, body: body}} ->
            check_api_errors(body)

          {:ok, %Req.Response{status: status, body: body}} ->
            Logger.warning("API-Football #{path} returned HTTP #{status}")
            {:error, {:http, status, body}}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  # API-Football returns 200 with an "errors" object on quota/auth problems.
  defp check_api_errors(%{"errors" => errors})
       when is_map(errors) and map_size(errors) > 0 do
    Logger.warning("API-Football errors: #{inspect(errors)}")
    {:error, {:api, errors}}
  end

  defp check_api_errors(body), do: {:ok, body}

  defp normalize_error({:error, _} = err), do: err
  defp normalize_error(other), do: {:error, {:unexpected, other}}

  defp config, do: Application.get_env(:elixir_project, :api_football, [])
  defp base_url, do: Keyword.get(config(), :base_url, "https://v3.football.api-sports.io")
  defp key, do: Keyword.get(config(), :key)
  def season, do: Keyword.get(config(), :season, 2023)
end
