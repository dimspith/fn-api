defmodule FnApi.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :fn_api
  @start_apps [:logger, :ecto, :ecto_sqlite3]

  def seed_path,
    do: System.get_env("FNAPI_SEEDS") || Application.app_dir(:fn_api, "priv" <> "/repo/seeds/")

  def migrate do
    ## Run migrations
    init(@app, @start_apps)

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seeds do
    ## Run seeds

    init(@app, @start_apps)

    run_seed_scripts(seed_path())

    stop()
  end

  def run_seed_scripts(seed_script) do
    ## Run all seed scripts in the specified directory

    IO.puts("Running seed script #{seed_script}..")

    "#{seed_path()}/*.exs"
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.each(fn x ->
      IO.puts("Running seed script #{x}..")
      Code.eval_file(x)
    end)
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp init(app, start_apps) do
    ## Initialize application
    IO.puts("Loading app..")
    :ok = load_app()

    IO.puts("Starting dependencies..")
    Enum.each(start_apps, &Application.ensure_all_started/1)

    IO.puts("Starting repos..")

    app
    |> Application.get_env(:ecto_repos, [])
    |> Enum.each(& &1.start_link(pool_size: 1))
  end

  defp stop do
    IO.puts("Success!")
    :init.stop()
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
