import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# Start the phoenix server if environment is set and running in a release
# if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
config :fn_api, FnApiWeb.Endpoint, server: true
config :fn_api, FnApiWeb.AdminEndpoint, server: true
# end

if config_env() == :prod do
  database_path =
    System.get_env("DATABASE_PATH") || "db/fnapi.db"
      # raise """
      # environment variable DATABASE_PATH is missing.
      # For example: /etc/fn_api/fn_api.db
      # """

  config :fn_api, FnApi.Database.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") || "ehsLE9d+kXqrvvEDqT3jmiWGrZE2A27pQltXilsl2TrWiYhn+oQ1RSYTfaor4yBEv"
      # raise """
      # environment variable SECRET_KEY_BASE is missing.
      # You can generate one by calling: mix phx.gen.secret
      # """

  host = System.get_env("PHX_HOST") || "localhost"

  config :fn_api, FnApiWeb.Endpoint,
    url: [host: host, port: 4000],
    http: [ip: {127, 0, 0, 1}, port: 4000],
    secret_key_base: secret_key_base,
    server: true

  config :fn_api, FnApiWeb.AdminEndpoint,
    # Binding to loopback ipv4 address prevents access from other machines.
    # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
    url: [host: host, port: 3000],
    http: [ip: {127, 0, 0, 1}, port: 3000],
    secret_key_base: secret_key_base,
    server: true

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :fn_api, FnApiWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
