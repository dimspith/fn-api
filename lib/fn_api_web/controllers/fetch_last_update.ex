defmodule FnApiWeb.FetchLastUpdate do
  use FnApiWeb, :controller
  import Ecto.Query
  alias FnApi.Repo
  alias FnApi.Blacklist

  def index(conn, _params) do
    json(conn, %{"lastupdate" => File.read!("priv/lists/lastupdate")
                 |> String.trim()
                 |> String.to_integer()})
  end
end
