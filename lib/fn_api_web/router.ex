defmodule FnApiWeb.Router do
  use FnApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FnApiWeb do
    pipe_through :api
    get "/fetch", FetchBlacklist, :index
    get "/latest", FetchLastUpdate, :index
    post "/label", LabelDomain, :index
  end
end
