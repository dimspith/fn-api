# Script for populating the database.
# It is ran on database creation.
# You can run it as:
#
#     mix run priv/repo/seeds.exs
#
alias FnApi.Database.{Repo, Insertions, Checkpoints}

# Options
chunk_size = 500


curr_datetime = DateTime.now!("Etc/UTC") |> DateTime.to_unix()

# Get default list file
File.stream!(Application.app_dir(:fn_api, "priv") <> "/lists/default")
# Chunk file every 500 lines
|> Stream.chunk_every(chunk_size)
|> Stream.map(fn list ->
  Enum.map(list, fn domain ->
    %{domain: String.trim(domain), date: curr_datetime}
  end)
end)
|> Enum.map(fn domains ->
  Ecto.Multi.new()
  |> Ecto.Multi.insert_all(:insert_all, Insertions, domains)
  |> Repo.transaction()
end)

Repo.insert(%Checkpoints{date: curr_datetime})

