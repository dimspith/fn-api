defmodule FnApiWeb.BlacklistController do
  use FnApiWeb, :controller
  import FnApi.Database.Updates

  def fetch_blacklist(conn, params) do
    case params do
      %{"checkpoint" => unix_time} -> send_diffs(conn, unix_time)
      _ -> send_all(conn)
    end
  end
  def send_all(conn) do
    json(conn, %{
      "sites" =>
        File.read!(blacklist_file())
        |> String.split("\n")
        |> (fn list -> List.delete_at(list, length(list) - 1) end).(),
      "checkpoint" => get_last_update()
    })
  end

  def send_diffs(conn, unix_time) do
    case Integer.parse(unix_time) do
      {date, _} ->
        diff = generate_diff(date)
        json(conn, %{
          "checkpoint" => get_last_update(),
          "insertions" => diff[:insert],
          "deletions" => diff[:delete]
        }) 
      :error ->
        json(conn, %{"error" => "Invalid checkpoint!"})
    end
  end
end
