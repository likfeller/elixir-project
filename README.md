# ⚽ Elixir Project — Football Analytics (Circuit HUD)

A real-time football analytics dashboard: a **Phoenix (Elixir) + Absinthe GraphQL**
backend serving a **React + TypeScript** single-page app that renders each player
as a futuristic *circuit-trace HUD* — stats fan out over the player's head along
animated PCB-style traces, themed in each team's colors.

Tracked teams: Real Madrid, Barcelona, Atlético Madrid, Paris Saint-Germain,
Bayern Munich, AC Milan, Liverpool (clubs) + Brazil, Poland, Albania (national).

## Architecture (monolith)

```
elixir_project/
├─ lib/elixir_project/football/      # context, Ecto schemas, API-Football client, sample data
├─ lib/elixir_project_web/           # GraphQL schema + resolvers, router, SPA controller
├─ lib/mix/tasks/football.sync.ex    # `mix football.sync` — pull real data from API-Football
├─ assets/                           # React + TypeScript + Vite frontend
│   └─ src/components/PlayerCircuit.tsx   # the circuit-trace HUD
└─ priv/static/                      # Vite build output, served by Phoenix
```

- **GraphQL API:** `POST /api/graphql` · explorer at `/graphiql`
- **Data:** API-Football (api-sports.io). Without a key, a built-in sample
  dataset is used so the dashboard always renders. Team crests load from the
  API-Sports CDN; national badges from flag images.

## Prerequisites

Installed via scoop (user profile): Erlang/OTP, Elixir, PostgreSQL. Plus Node.
The scoop binaries live under `%USERPROFILE%\scoop`; if a new shell can't find
`elixir`/`mix`/`psql`, prepend them to PATH:

```powershell
$sc = "$env:USERPROFILE\scoop"
$env:Path = "$sc\shims;$sc\apps\elixir\current\bin;$sc\apps\postgresql\current\bin;" + $env:Path
```

## Run (development)

```powershell
# 1. Start PostgreSQL (once per machine boot)
pg_ctl start -D "$env:USERPROFILE\scoop\apps\postgresql\current\data"

# 2. Backend deps + database
mix setup                 # deps.get + ecto.create + migrate + seed

# 3. Frontend deps (once)
cd assets; npm install; cd ..

# 4. Start the app (also rebuilds the frontend on change)
mix phx.server
```

Open <http://localhost:4000>.

For frontend hot-reload during heavy UI work, run `npm run dev` in `assets/`
(serves on :5173 and proxies the API to :4000).

## Using real API-Football data

1. Get a free key at <https://dashboard.api-football.com> (100 req/day).
2. Copy `config/dev.secret.exs.example` → `config/dev.secret.exs` and paste your key.
   (Or set the `API_FOOTBALL_KEY` environment variable.)
3. Pull real squads, player photos, stats and crests:

   ```powershell
   mix football.sync
   ```

   Player photos and exact crests then appear automatically. Mind the free-tier
   rate limit — the sync is sequential and paced.
