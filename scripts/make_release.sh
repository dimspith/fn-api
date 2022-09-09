export MIX_ENV=prod

mix deps.get --only prod
mix compile
mix phx.gen.release
mix release 
