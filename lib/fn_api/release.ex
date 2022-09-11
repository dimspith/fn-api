defmodule FnApi.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :fn_api
  @start_apps [:logger, :ecto, :ecto_sqlite3]
  @seed_path Application.app_dir(:fn_api, "priv" <> "/repo/seeds.exs")

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
    
    run_seed_script(@seed_path)

    stop()
  end

  defp run_seed_script(seed_script) do
    IO.puts "Running seed script #{seed_script}.."
    Code.eval_file(seed_script)
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp init(app, start_apps) do
    ## Initialize application
    IO.puts "Loading app.."
    :ok = load_app()

    IO.puts "Starting dependencies.."
    Enum.each(start_apps, &Application.ensure_all_started/1)

    IO.puts "Starting repos.."
    app
    |> Application.get_env(:ecto_repos, [])
    |> Enum.each(&(&1.start_link(pool_size: 1)))
  end

  defp stop do
    IO.puts "Success!"
    :init.stop()
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
