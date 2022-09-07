defmodule FnApiWeb.AdminRouter do
  use FnApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/list", FnApiWeb do
    pipe_through :api
    post "/update", Admin.UpdateBlacklist, :update
  end

  scope "/users", FnApiWeb do
    pipe_through :api
    post "/create", Admin.UserManager, :create
    post "/delete", Admin.UserManager, :delete
    get "/get", Admin.UserManager, :get
    get "/getAll", Admin.UserManager, :get_all
  end
end
