defmodule FnApiWeb.LabelController do
  use FnApiWeb, :controller
  require Logger
  import FnApi.Database.Labelling
  # import FnApi

  # Convert plaintext list to json file
  def submit_label(conn, params) do
    Logger.info(params)
    res = insert_label(params)
    json(conn, res)
  end
end
