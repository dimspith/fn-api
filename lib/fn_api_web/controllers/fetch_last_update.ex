defmodule FnApiWeb.FetchLastUpdate do
  use FnApiWeb, :controller
  import FnApi.Utils

  def index(conn, _params) do
    json(conn, %{"lastupdate" => get_last_update()})
  end
end
