defmodule FnApiWeb.CheckpointController do
  use FnApiWeb, :controller
  import FnApi.Database.Updates

  def last_checkpoint(conn, _params) do
    json(conn, %{"checkpoint" => get_last_update()})
  end
end
