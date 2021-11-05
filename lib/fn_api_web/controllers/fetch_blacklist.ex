defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller
  
  File.write("priv/list.json", Jason.encode! %{"sites" => File.read!("priv/list")
                                            |> String.split("\n", trim: true)
                                            |> Enum.map(fn x -> "*://*." <> x <> "/*" end)})
  
  def index(conn, _params) do
    send_file(conn, 200, "priv/list.json")
  end
end
