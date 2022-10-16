defmodule FnApiWeb.LabelDomain do
  use FnApiWeb, :controller
  require Logger
  import FnApi.Database.Labelling
  # import FnApi

  # Convert plaintext list to json file
  def index(conn, params) do
    Logger.info(params)
    res = insert_label(params)
    json(conn, res)
  end
end

