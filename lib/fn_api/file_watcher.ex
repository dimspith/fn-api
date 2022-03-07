defmodule FnApi.FileWatcher do
  use GenServer
  import Ecto.Query
  alias FnApi.{Repo, Insertions, Deletions}

  def fetch_file_changes(path) do
    file = File.read!(path)

    if(file == "") do
      {:error, "file is empty"}
    else
      lines =
        file
        |> String.split("\n")
        |> Enum.map(fn x -> String.split(x, " ") end)

      changes =
        Enum.reduce(lines, %{add: [], rm: []}, fn x, acc ->
          case Enum.at(x, 0) do
            "+" -> Map.update!(acc, :add, &[Enum.at(x, 1) | &1])
            "-" -> Map.update!(acc, :rm, &[Enum.at(x, 1) | &1])
            _ -> acc
          end
        end)

      datetime = DateTime.now!("Etc/UTC") |> DateTime.to_unix()

      Enum.map(Map.fetch!(changes, :add), fn x ->
        changes =
          %Insertions{}
          |> Insertions.changeset(%{domain: x, date: datetime})

        case Repo.insert(changes) do
          {:ok, _} -> IO.puts("Insertion successful!")
          {:error, _} -> IO.puts("Error: Insertion failed!")
        end
      end)

      Enum.each(Map.fetch!(changes, :rm), fn x ->
        changes =
          %Deletions{}
          |> Deletions.changeset(%{domain: x, date: datetime})

        case Repo.insert(changes) do
          {:ok, _} -> IO.puts("Insertion successful!")
          {:error, _} -> IO.puts("Error: Insertion failed!")
        end
      end)
      {:ok, :success}
    end
  end

  def generate_blacklist(path) do
    insertions = Repo.all(from(d in Insertions, select: d.domain))
    deletions = Repo.all(from(d in Deletions, select: d.domain))

    File.write!(
      path,
      (insertions -- deletions)
      |> Enum.map(fn x -> x <> "\n" end)
    )
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)
    
    # generate_blacklist("priv/lists/blacklist")
    
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    if(Enum.member?(events, :closed)) do
      fetch_file_changes(path)
      generate_blacklist("priv/lists/blacklist")
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    {:noreply, state}
  end
end
