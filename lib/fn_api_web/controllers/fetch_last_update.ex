defmodule FnApiWeb.FetchLastUpdate do
  use FnApiWeb, :controller
  import Ecto.Query
  alias FnApi.{Insertions, Deletions, Repo}

  def index(conn, _params) do
    json(conn, %{
      "lastupdate" =>
        hd(
          max(
            Repo.all(from i in Insertions, select: max(i.date)),
            Repo.all(from d in Deletions, select: max(d.date))
          )
        )
    })
  end
end
