defmodule ElixirProjectWeb.PageController do
  use ElixirProjectWeb, :controller

  @doc """
  Serves the built React single-page app (priv/static/index.html).

  Until the frontend is built, shows a placeholder page pointing at the
  GraphQL explorer so the backend is usable on its own.
  """
  def index(conn, _params) do
    index = Path.join(:code.priv_dir(:elixir_project), "static/index.html")

    if File.exists?(index) do
      conn
      |> put_resp_content_type("text/html")
      |> send_file(200, index)
    else
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, placeholder_html())
    end
  end

  defp placeholder_html do
    """
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Elixir Project — Football Analytics</title>
        <style>
          body { margin:0; font-family: system-ui, sans-serif; background:#0a1930;
                 color:#e6edf6; display:grid; place-items:center; height:100vh; }
          .card { text-align:center; max-width:34rem; padding:2rem; }
          h1 { font-weight:800; letter-spacing:-.02em; }
          code { background:#13233f; padding:.15rem .4rem; border-radius:.3rem; }
          a { color:#febe10; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>⚽ Football Analytics API is running</h1>
          <p>The React dashboard hasn't been built yet. Build it from
             <code>assets/</code> with <code>npm run build</code>.</p>
          <p>Explore the GraphQL API at <a href="/graphiql">/graphiql</a>.</p>
        </div>
      </body>
    </html>
    """
  end
end
