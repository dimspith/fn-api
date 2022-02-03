defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller

  # Reload module when lists change
  @external_resource "priv/list"
  @external_resource "priv/list.json"
  
  # Convert plaintext list to json file
  File.write("priv/list.json",
    Jason.encode! %{"sites" => File.read!("priv/list")
                    |> String.split("\n", trim: true)})
  
  def index(conn, _params) do
    send_file(conn, 200, "priv/list.json")
  end
end
