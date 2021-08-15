defmodule FnApiWeb.FetchBlacklist do
  use FnApiWeb, :controller

  @blacklist %{"sites" => ["*://*.google.com/*", "*://*.youtube.com/*"]}

  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(@blacklist))
  end
end
