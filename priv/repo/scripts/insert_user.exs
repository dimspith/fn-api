import Ecto.UUID
alias FnApi.Database.{Repo, Tokens}

args = System.argv()
if(Enum.empty?(args)) do
  IO.puts("Please insert a name for the new user!")
else
  [name] = Enum.take(args, 1)
  Repo.insert(%Tokens{fullName: name})
  IO.puts(load! Repo.get_by(Tokens, fullName: name).uuid)
end



