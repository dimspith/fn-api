Logger.configure([level: :error])

import Ecto.Query
import Ecto.UUID
alias FnApi.{Repo, Tokens}

# Get all names and uuids from users
users =
  Repo.all(from t in Tokens, select: [t.uuid, t.fullName])
  |> Enum.map(fn [uuid, name] -> [load!(uuid), name] end)

# Pretty print
Enum.each(users, fn token -> IO.inspect(List.flatten(token), pretty: true) end)
