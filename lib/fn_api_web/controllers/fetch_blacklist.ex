defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller

  def index(conn, _params) do
    json(conn, %{"sites" =>
                  File.read!("priv/lists/blacklist")
                  |> String.split("\n")
                  |> Enum.sort()})
  end
end
