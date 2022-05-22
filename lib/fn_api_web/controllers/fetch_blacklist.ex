defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller
  import FnApi.Database.Updates

  def send_all(conn) do
    json(conn, %{
      "sites" =>
        File.read!("priv/lists/blacklist")
        |> String.split("\n")
        |> (fn list -> List.delete_at(list, length(list) - 1) end).(),
      "lastupdate" => get_last_update()
    })
  end

  def send_diffs(conn, unix_time) do
    case Integer.parse(unix_time) do
      {date, _} ->
        diff = generate_diff(date)

        json(conn, %{
          "lastupdate" => get_last_update(),
          "insertions" => diff[:insertions],
          "deletions" => diff[:deletions]
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
