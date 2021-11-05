defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller
  
  File.write!("priv/top1m.json", Jason.encode! %{"sites" => File.read!("priv/top1m.bcp")
                                            |> String.split("\n", trim: true)
                                            |> Enum.map(fn x -> "*://*." <> x <> "/*" end)})


  def index(conn, _params) do
    send_file(conn, 200, "top1m.json")
  end
end
