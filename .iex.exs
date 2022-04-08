import Ecto.Query
alias FnApi.{Repo, Insertions, Deletions, Checkpoints, Labels, Tokens, Tags}

defmodule IU do
  def iex_tbn(fullName) do
    Ecto.UUID.load! Repo.get_by(Tokens, fullName: fullName).uuid
  end
  def insert_token(name) do
    Repo.insert(%Tokens{fullName: name})
    iex_tbn(name)
  end
end

