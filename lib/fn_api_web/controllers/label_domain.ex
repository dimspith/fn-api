defmodule FnApiWeb.LabelDomain do
  use FnApiWeb, :controller
  
  # Convert plaintext list to json file
  def index(conn, params) do
    json(conn, params)
  end
end
