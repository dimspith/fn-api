defmodule FnApi.FileWatcher do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {_path, events}}, %{watcher_pid: watcher_pid} = state) do
    if(Enum.member?(events, :closed)) do
        IO.puts("FILE MODIFIED!")
    end
      
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do

    # Your own logic when monitor stop
    {:noreply, state}
  end
end
