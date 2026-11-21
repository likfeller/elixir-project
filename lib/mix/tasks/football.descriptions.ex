defmodule Mix.Tasks.Football.Descriptions do
  @moduledoc """
  Fetch a scouting-style description for every player from Wikipedia (what type
  of player they are / why they're valued) and store it on `players.description`.

      mix football.descriptions

  No API key needed. Uses the Wikipedia search + REST summary APIs.
  """
  use Mix.Task
  import Ecto.Query

  alias ElixirProject.Repo
  alias ElixirProject.Football.Player

  @shortdoc "Fetch player descriptions from Wikipedia"
  @requirements ["app.start"]
  @ua "ElixirProjectFootballDashboard/0.1 (educational project; contact: leo@chaisarcapital.com)"

  @impl true
  def run(_args) do
    names =
      Repo.all(from p in Player, select: p.name, distinct: true)
      |> Enum.sort()

    Mix.shell().info("Fetching descriptions for #{length(names)} players from Wikipedia...")

    descriptions =
      Enum.reduce(names, %{}, fn name, acc ->
        Process.sleep(200)

        case wiki_extract(name) do
          {:ok, text} ->
            Mix.shell().info("  ✓ #{name}")
            Map.put(acc, name, text)

          :error ->
            Mix.shell().error("  ✗ #{name} (no description found)")
            acc
        end
      end)

    updated =
      Enum.reduce(descriptions, 0, fn {name, text}, n ->
        {count, _} =
          Repo.update_all(from(p in Player, where: p.name == ^name), set: [description: text])

        n + count
      end)

    Mix.shell().info(
      "Updated #{updated} player rows (#{map_size(descriptions)}/#{length(names)} names matched)."
    )
  end

  defp wiki_extract(name) do
    with {:ok, title} <- search_title(name),
         {:ok, text} <- summary_extract(title) do
      {:ok, text}
    else
      _ -> :error
    end
  end

  defp search_title(name) do
    params = [
      action: "query",
      list: "search",
      srsearch: name <> " footballer",
      format: "json",
      srlimit: 1
    ]

    case Req.get("https://en.wikipedia.org/w/api.php",
           params: params,
           headers: [{"user-agent", @ua}],
           retry: false
         ) do
      {:ok, %{status: 200, body: %{"query" => %{"search" => [%{"title" => title} | _]}}}} ->
        {:ok, title}

      _ ->
        :error
    end
  end

  defp summary_extract(title) do
    url = "https://en.wikipedia.org/api/rest_v1/page/summary/" <> URI.encode(title)

    case Req.get(url, headers: [{"user-agent", @ua}], retry: false) do
      {:ok, %{status: 200, body: %{"extract" => extract}}}
      when is_binary(extract) and extract != "" ->
        {:ok, extract}

      _ ->
        :error
    end
  end
end
