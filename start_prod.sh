export SECRET_KEY_BASE="$(mix phx.gen.secret)"
export DATABASE_PATH="db/fnapi_prod.db"
export MIX_ENV=prod

mix ecto.setup
mix phx.server
