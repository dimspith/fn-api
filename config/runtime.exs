import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# Start the phoenix server if environment is set and running in a release
# if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  # config :fn_api, FnApiWeb.Endpoint, server: true
  # config :fn_api, FnApiWeb.AdminEndpoint, server: true
# end

if config_env() == :prod do
  database_path = System.get_env("DATABASE_PATH") || "db/fnapi.db"
  secret_key_base = System.get_env("SECRET_KEY_BASE") || "ehsLE9d+kXqrvvEDqT3jmiWGrZE2A27pQltXilsl2TrWiYhn+oQ1RSYTfaor4yBEv"
  live_view_salt = System.get_env("LIVE_VIEW_SALT") || "d8dnNoWXbMNDZCT1gnk5VRC2EZOvugrH"
  host = System.get_env("PHX_HOST") || "localhost"

  # Database config
  config :fn_api, FnApi.Database.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # User API
  config :fn_api, FnApiWeb.Endpoint,
    url: [host: host, port: 4000],
    http: [ip: {127, 0, 0, 1}, port: 4000],
    secret_key_base: secret_key_base,
    server: true

  # Admin API
  config :fn_api, FnApiWeb.AdminEndpoint,
    # Binding to loopback ipv4 address prevents access from other machines.
    # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
    url: [host: host, port: 3000],
    http: [ip: {127, 0, 0, 1}, port: 3000],
    secret_key_base: secret_key_base,
    pubsub_server: FnApi.PubSub,
    live_view: [signing_salt: live_view_salt],
    server: true
end
