# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FnApi.Repo.insert!(%FnApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# alias FnApi.Repo

# list =
#   File.read!("priv/lists/list")
#   |> String.split("\n", trim: true)
#   |> Enum.sort()

# Enum.each(list, fn (domain) -> Repo.insert!(%FnApi.Blacklist{domain: domain}) end)
