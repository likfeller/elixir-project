defmodule ElixirProject.Football.Wikipedia do
  @moduledoc """
  Tiny helper over the Wikipedia search + REST summary APIs to fetch a player's
  photo and a short description. No API key needed.
  """
  @ua "ElixirProjectFootballDashboard/0.1 (educational project; contact: leo@chaisarcapital.com)"

  @doc """
  Returns `%{photo: url_or_nil, description: text_or_nil}` for a player name,
  or `nil` if nothing is found.
  """
  def lookup(name) do
    with {:ok, title} <- search_title(name),
         {:ok, summary} <- summary(title) do
      %{
        photo: get_in(summary, ["thumbnail", "source"]) |> strip_query(),
        description: summary["extract"]
      }
    else
      _ -> nil
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

  defp summary(title) do
    url = "https://en.wikipedia.org/api/rest_v1/page/summary/" <> URI.encode(title)

    case Req.get(url, headers: [{"user-agent", @ua}], retry: false) do
      {:ok, %{status: 200, body: body}} when is_map(body) -> {:ok, body}
      _ -> :error
    end
  end

  defp strip_query(nil), do: nil
  defp strip_query(url), do: url |> String.split("?") |> hd()
end
