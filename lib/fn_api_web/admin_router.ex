defmodule FnApiWeb.AdminRouter do
  use FnApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

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

  import Phoenix.LiveDashboard.Router
  scope "/" do
    pipe_through [:browser]
    live_dashboard "/dashboard", metrics: FnApiWeb.Telemetry
  end
end
