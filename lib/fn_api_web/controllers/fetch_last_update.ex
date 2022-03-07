defmodule FnApiWeb.FetchLastUpdate do
  use FnApiWeb, :controller
  import Ecto.Query
  alias FnApi.{Insertions, Deletions, Repo}
  import FnApi.Utils

  def index(conn, _params) do
    json(conn, %{"lastupdate" => get_last_update()})
  end
end
