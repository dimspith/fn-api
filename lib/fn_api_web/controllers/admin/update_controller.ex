defmodule FnApiWeb.Admin.UpdateBlacklist do
  use FnApiWeb, :controller
  require Logger
  import FnApi.Database.Updates

  def map_keys_exist?(map, keys) do
    ## Check if any of the keys exist in the map
    keys |> Enum.any?(&Map.has_key?(map, &1))
  end

  def map_fix_params(map) do
    map
    |> Map.take(["insert", "delete"])
    |> Map.put_new("insert", [])
    |> Map.put_new("delete", [])
  end

  def update(conn, params) do
    case map_keys_exist?(params, ["insert", "delete"]) do
      false ->
        conn
        |> put_status(400)
        |> json(%{"error" => "No insertions or deletions supplied!"})

      true ->
        case db_add_all(params |> map_fix_params()) do
          {:ok, _} ->
            update_blacklist_file()
            json(conn, %{"success" => "Blacklist updated successfully!"})
        end
    end
  end
end
