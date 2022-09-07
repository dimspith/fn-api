defmodule FnApiWeb.Admin.UpdateBlacklist do
  use FnApiWeb, :controller

  def index(conn, _params) do
    
    json(conn, %{"lastupdate" => 1})
  end
end

