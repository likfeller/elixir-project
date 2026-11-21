defmodule Mix.Tasks.Football.Photos do
  @moduledoc """
  Fetch a real photo for every player from Wikipedia and store it on the
  player's `photo` field (used as the card background in the dashboard).

      mix football.photos

  No API key needed. Uses the Wikipedia search + REST summary APIs. Players are
  de-duplicated by name, and requests are lightly paced to be polite.
  """
  use Mix.Task
  import Ecto.Query

  alias ElixirProject.Repo
  alias ElixirProject.Football.Player

  @shortdoc "Fetch player photos from Wikipedia"
  @requirements ["app.start"]
  @ua "ElixirProjectFootballDashboard/0.1 (educational project; contact: leo@chaisarcapital.com)"

  @impl true
  def run(_args) do
    names =
      Repo.all(from p in Player, select: p.name, distinct: true)
      |> Enum.sort()

    Mix.shell().info("Fetching photos for #{length(names)} players from Wikipedia...")

    photos =
      Enum.reduce(names, %{}, fn name, acc ->
        Process.sleep(200)

        case wiki_photo(name) do
          {:ok, url} ->
            Mix.shell().info("  ✓ #{name}")
            Map.put(acc, name, url)

          :error ->
            Mix.shell().error("  ✗ #{name} (no photo found)")
            acc
        end
      end)

    updated =
      Enum.reduce(photos, 0, fn {name, url}, n ->
        {count, _} =
          Repo.update_all(from(p in Player, where: p.name == ^name), set: [photo: url])

        n + count
      end)

    Mix.shell().info("Updated #{updated} player rows with photos (#{map_size(photos)}/#{length(names)} names matched).")
  end

  defp wiki_photo(name) do
    with {:ok, title} <- search_title(name),
         {:ok, url} <- summary_image(title) do
      {:ok, url}
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

  defp summary_image(title) do
    url = "https://en.wikipedia.org/api/rest_v1/page/summary/" <> URI.encode(title)

    case Req.get(url, headers: [{"user-agent", @ua}], retry: false) do
      {:ok, %{status: 200, body: body}} ->
        case get_in(body, ["thumbnail", "source"]) || get_in(body, ["originalimage", "source"]) do
          nil -> :error
          # Drop the tracking query string — keep a clean, shorter image URL.
          img -> {:ok, img |> String.split("?") |> hd()}
        end

      _ ->
        :error
    end
  end
end
