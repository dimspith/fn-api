defmodule FnApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FnApi.Repo,
      # Start the filesystem watcher
      {FnApi.FileWatcher, dirs: ["priv/lists/changes"]},
      # Start the Telemetry supervisor
      FnApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FnApi.PubSub},
      # Start the Endpoint (http/https)
      FnApiWeb.Endpoint
      # Start a worker by calling: FnApi.Worker.start_link(arg)
      # {FnApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FnApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FnApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
