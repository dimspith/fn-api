defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller
  import FnApi.Utils

  def send_all(conn) do
    json(conn, %{
      "sites" =>
        File.read!("priv/lists/blacklist")
        |> String.split("\n")
        |> (fn list -> List.delete_at(list, length(list)-1) end).()
    })
  end

  def send_diffs(conn, unix_time) do
    case Integer.parse(unix_time) do
      {date, _} ->
        diff = generate_diff(date)
        IO.inspect(diff)

        json(conn, %{
          "lastupdate" => get_last_update(),
          "insertions" => Map.get(diff, :insertions),
          "deletions" => Map.get(diff, :deletions)
        })

      :error ->
        json(conn, %{"error" => "Invalid unix timestamp!"})
    end
  end

  def index(conn, params) do
    case params do
      %{"lastupdate" => unix_time} -> send_diffs(conn, unix_time)
      _ -> send_all(conn)
    end
  end
end
