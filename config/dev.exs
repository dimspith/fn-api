import Config

# Configure your database
config :fn_api, FnApi.Database.Repo,
  database: Path.expand("../db/fn_api_dev.db", Path.dirname(__ENV__.file)),
  pool_size: 20,
  show_sensitive_data_on_connection_error: true

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :fn_api, FnApiWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: false,
  secret_key_base: "dtfRv3Jr9Ndvqybq15EG7MCMbnK/AMc2hMvirEGkUOvl8wA4Yc0ZVgvQd9SFOWle",
  watchers: []

config :fn_api, FnApiWeb.AdminEndpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 3000],
  check_origin: false,
  code_reloader: true,
  debug_errors: false,
  secret_key_base: "dtfRv3Jr9Ndvqybq15EG7MCMbnK/AMc2hMvirEGkUOvl8wA4Yc0ZVgvQd9SFOWle",
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
