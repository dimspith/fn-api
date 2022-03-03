defmodule FnApiWeb.MarkDomain do
  use FnApiWeb, :controller
  
  # Convert plaintext list to json file
  def index(conn, params) do
    json(conn, %{body: params})
  end
end
