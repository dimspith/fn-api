# FakeNews API

A really simple API that serves a json list of sites to be blocked 
by the [chrome extension](https://github.com/dimspith/fn-blacklist).

### Installing
Follow the [official guide](https://hexdocs.pm/phoenix/installation.html) to install Phoenix

### Running in Development Mode
To start the server:
  * Install dependencies with `mix deps.get`
  * Initialize database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`
    * To start in interactive mode use `iex -S mix phx.server`

### Running in Production Mode
  * Install dependencies with `mix deps.get`
  * Initialize database with `mix ecto.setup`
  * Start Phoenix endpoint by running the script `./start_prod.sh`
