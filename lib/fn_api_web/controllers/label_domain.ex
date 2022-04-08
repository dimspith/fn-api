defmodule FnApiWeb.LabelDomain do
  use FnApiWeb, :controller
  import FnApi.Labelling
  
  # Convert plaintext list to json file
  def index(conn, params) do
    res = db_insert_label(params)
    json(conn, res)
  end
end
