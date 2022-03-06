defmodule FnApi.FileWatcher do
  use GenServer
  import Ecto.Query
  import Ecto.Changeset
  alias FnApi.Repo
  alias FnApi.Insertions
  alias FnApi.Deletions

  def fetch_file_changes(path) do
    file =
      File.read!(path)
      |> String.split("\n")
      |> Enum.map(fn x -> String.split(x, " ") end)

    changes =
      Enum.reduce(file, %{add: [], rm: []}, fn x, acc ->
        case Enum.at(x, 0) do
          "+" -> Map.update!(acc, :add, &[Enum.at(x, 1) | &1])
          "-" -> Map.update!(acc, :rm, &[Enum.at(x, 1) | &1])
          _ -> acc
        end
      end)

    datetime = DateTime.now!("Etc/UTC") |> DateTime.to_unix()

    Enum.map(Map.fetch!(changes, :add), fn x ->
      changes = %Insertions{}
      |> Insertions.changeset(%{domain: x, date: datetime})
      
      case Repo.insert(changes) do
        {:ok, _}       -> IO.puts("Insertion successful!")
        {:error, _}    -> IO.puts("Error: Insertion failed!")
      end
    end)

    Enum.map(Map.fetch!(changes, :rm), fn x ->
      changes = %Deletions{}
      |> Deletions.changeset(%{domain: x, date: datetime})
      
      case Repo.insert(changes) do
        {:ok, _}       -> IO.puts("Insertion successful!")
        {:error, _}    -> IO.puts("Error: Insertion failed!")
      end
    end)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    if(Enum.member?(events, :closed)) do
      fetch_file_changes(path)
      IO.puts("FILE MODIFIED!")
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    {:noreply, state}
  end
end
