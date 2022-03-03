defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller
  import Ecto.Query
  alias FnApi.Repo
  alias FnApi.Blacklist

  # Reload module when lists change
  @external_resource "priv/lists/list"
  @external_resource "priv/lists/list.json"

  def index(conn, _params) do
    send_file(conn, 200, "priv/lists/list.json")
    json(conn, Jason.encode!(%{"sites" => Repo.all(from(i in Blacklist, select: i.domain))}))
  end
end
