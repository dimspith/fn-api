# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

import Ecto.Query
alias FnApi.{Repo, Insertions, Checkpoints}

curr_datetime = DateTime.now!("Etc/UTC") |> DateTime.to_unix()

File.stream!("priv/lists/default")|> Enum.each(fn domain ->
  domain
  |> String.trim()
  |> (fn domain ->
    Repo.insert!(%Insertions{domain: domain, date: curr_datetime})
  end).()
end)

Repo.insert(%Checkpoints{date: curr_datetime})
