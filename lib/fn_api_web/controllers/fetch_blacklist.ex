defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller
  import Ecto.Query
  alias FnApi.{Insertions, Deletions, Repo}
  import FnApi.Utils

  def send_all(conn) do
    json(conn, %{
      "sites" =>
        File.read!("priv/lists/blacklist")
        |> String.split("\n")
        |> Enum.sort()
    })
  end

  def send_diffs(conn, unix_time) do
    case Integer.parse(unix_time) do
      {date, _} ->
        diff = generate_diff(date)
        IO.inspect(diff)

        json(conn, %{
          "lastupdate" => date,
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
