SCRIPTS_DIR="$(realpath $( dirname -- "$0"; ))"
PROJECT_DIR="$( dirname -- "$SCRIPTS_DIR"; )"
RELEASE_DIR="$PROJECT_DIR/_build/prod/rel/"
RELEASE_FILE="$PROJECT_DIR/release.zip"

cd "$PROJECT_DIR"
export MIX_ENV=prod
mix deps.get --only prod
mix compile
#mix phx.gen.release --ecto
mix release 

echo "Compressing release into archive..."

# Add startup script
cd "$SCRIPTS_DIR"
zip -9r "$RELEASE_FILE" manage

# Add release
cd "$RELEASE_DIR"
zip -ur "$RELEASE_FILE" ./fn_api

echo "Release archive release.zip has been generated!"
