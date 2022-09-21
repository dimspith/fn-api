defmodule FnApiWeb.Router do
  use FnApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/list/", FnApiWeb do
    pipe_through :api
    get "/get", FetchBlacklist, :index
    get "/last-update", FetchLastUpdate, :index
    post "/label", LabelDomain, :index
  end
end
