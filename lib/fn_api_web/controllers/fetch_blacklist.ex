defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller
  import Ecto.Query
  alias FnApi.Repo
  alias FnApi.Blacklist

  def index(conn, _params) do
    json(conn, %{"sites" => Repo.all(from(i in Blacklist, select: i.domain)) |> Enum.sort()})
  end
end
