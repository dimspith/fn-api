defmodule FnApiWeb.Router do
  use FnApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/list/", FnApiWeb do
    pipe_through :api
    get "/get", BlacklistController, :fetch_blacklist
    get "/last-checkpoint", CheckpointController, :last_checkpoint
    post "/label", LabelController, :submit_label
  end
end
