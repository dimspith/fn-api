defmodule FnApi.FileWatcher do
  @moduledoc """
  Watches for changes in the file or directory supplied as an argument when initialized.
  When changes occur, it fetches the additions and removals from the file and commits them to the database.
  Also generates a file containing the latest list on each change.
  """

  use GenServer
  import Ecto.Query
  import FnApi.Utils
  alias FnApi.{Repo, Insertions, Deletions, Checkpoints}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)

    generate_diff()

    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    if(Enum.member?(events, :closed)) do
      case fetch_changes(path) do
        {:error, _} -> :error
        {:ok, _} -> generate_diff()
      end
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    {:noreply, state}
  end
end
