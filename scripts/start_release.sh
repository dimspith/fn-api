#!/bin/bash

# The script's current directory relative to where it's called from
DIR="$( dirname -- "$0"; )"

# Default environment variables
export USER_PORT=${USER_PORT-4000}
export ADMIN_PORT=${ADMIN_PORT-3000}
export ADMIN_PORT=${ADMIN_PORT-3000}
export PHX_HOST=${PHX_HOST-"localhost"}
export POOL_SIZE=${POOL_SIZE-5}

if [ "$1" == "migrate" ]; then
  echo "Running Release migrations..."
  mkdir -p "$DIR"/db
  "$DIR"/fn_api/bin/fn_api eval "FnApi.Release.migrate"
  echo "Running database seeds..."
  "$DIR"/fn_api/bin/fn_api eval "FnApi.Release.seeds"
  exit
else
  echo "============ ENV INFO ============="
  echo "-> USER_PORT: $USER_PORT"
  echo "-> ADMIN_PORT: $ADMIN_PORT"
  echo "-> PHX_HOST: $PHX_HOST"
  echo "-> POOL_SIZE: $POOL_SIZE"
  echo "==================================="

  "$DIR"/fn_api/bin/fn_api $1 

fi
