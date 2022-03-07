defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller
  import Ecto.Query
  alias FnApi.{Insertions, Deletions, Repo}

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
        insertions =
          Repo.all(from i in Insertions, where: i.date > ^date, select: i.domain)

        deletions =
          Repo.all(from d in Deletions, where: d.date > ^date, select: d.domain)
        IO.inspect(insertions)
        json(conn, %{"lastupdate" => date,
                     "insertions" => insertions ,
                    })
      :error -> json(conn, %{"error" => "Invalid unix timestamp!"})
    end
  end

  def index(conn, params) do
    case params do
      %{"lastupdate" => unix_time} -> send_diffs(conn, unix_time)
      _ -> send_all(conn)
    end
  end
end
