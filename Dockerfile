# Stage 1
# Builds the release
FROM hexpm/elixir:1.14.0-erlang-24.3.4.2-debian-bullseye-20210902-slim AS build

RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        build-essential git && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Build for production
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# Compile and build the release
COPY rel rel
COPY lib lib
COPY priv priv
RUN mix do compile, release fn_api

# Stage 2
# Prepares the runtime environment and copies over the release.
FROM hexpm/elixir:1.14.0-erlang-24.3.4.2-debian-bullseye-20210902-slim

RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        # Runtime dependencies
        build-essential ca-certificates libncurses5-dev \
        # In case someone uses `Mix.install/2` and point to a git repo
        git \
        # Additional standard tools
        wget &&\
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Run in the /data directory by default, makes for
# a good place for the user to mount local volume
WORKDIR /data

ENV HOME=/home/fnapi
# Make sure someone running the container with `--user`
# has permissions to the home dir (for `Mix.install/2` cache)
RUN mkdir $HOME && chmod 777 $HOME

# Install hex and rebar for `Mix.install/2` and Mix runtime
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy the release build from the previous stage
COPY --from=build /app/_build/prod/rel/fn_api /app/fn_api

# Copy files
COPY scripts/manage /app/manage

RUN mkdir /app/files
COPY priv/defaults /app/files/defaults
CMD touch /app/files/blacklist
COPY priv/repo/seeds /app/files/seeds

# Make release files available to any user, in case someone
# runs the container with `--user`
RUN chmod -R go=u /app

ENV USER_PORT=4000
ENV ADMIN_PORT=3000
ENV PHX_HOST=localhost
ENV POOL_SIZE=10
ENV DATABASE_PATH="/app/db/fnapi.db"
ENV FNAPI_DEFAULTS="/app/files/defaults/"
ENV FNAPI_BLACKLIST="/app/files/blacklist"
ENV FNAPI_SEEDS="/app/files/seeds/"


# Run migrations and seeds
RUN ls -la /app
RUN /app/manage migrate

# Run fn_api
CMD /app/manage start
