# Script for populating the database.
# It is ran on database creation.
# You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias FnApi.Database.{Repo, Insertions, Checkpoints}

curr_datetime = DateTime.now!("Etc/UTC") |> DateTime.to_unix()

File.stream!("priv/lists/default")|> Enum.each(fn domain ->
  domain
  |> String.trim()
  |> (fn domain ->
    Repo.insert!(%Insertions{domain: domain, date: curr_datetime})
  end).()
end)

Repo.insert(%Checkpoints{date: curr_datetime})
