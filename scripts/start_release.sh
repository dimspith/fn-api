#!/bin/bash

# The script's current directory relative to where it's called from
DIR="$( dirname -- "$0"; )"

# Default environment variables
USER_PORT=${USER_PORT-4000}
ADMIN_PORT=${ADMIN_PORT-3000}
ADMIN_PORT=${ADMIN_PORT-3000}
PHX_HOST=${PHX_HOST-"localhost"}
POOL_SIZE=${POOL_SIZE-5}

if [ "$1" == "migrate" ]; then
  echo "Running Release migrations..."
  "$DIR"/fn_api/bin/fn_api eval "FnApi.Release.migrate"
  exit
fi

echo "============ INFO ============="
echo "-> USER_PORT: $USER_PORT"
echo "-> ADMIN_PORT: $ADMIN_PORT"
echo "-> PHX_HOST: $PHX_HOST"
echo "-> POOL_SIZE: $POOL_SIZE"
echo "==============================="

"$DIR"/fn_api/bin/fn_api start 
