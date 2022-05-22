defmodule FnApiWeb.LabelDomain do
  use FnApiWeb, :controller
  import FnApi.Database.Labelling
  
  # Convert plaintext list to json file
  def index(conn, params) do
    res = insert_label(params)
    json(conn, res)
  end
end
