defmodule FnApi.Database.Repo do
  use Ecto.Repo,
    otp_app: :fn_api,
    adapter: Ecto.Adapters.SQLite3,
    temp_store: :memory,
    synchronous: :extra
end
