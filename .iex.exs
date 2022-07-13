import Ecto.Query
alias FnApi.Database.{Repo, Insertions, Deletions, Checkpoints, Labels, Tokens, Tags}

defmodule IU do
  def get_uuid(fullName) do
    Repo.get_by(Tokens, fullName: fullName).uuid
  end
  def insert_token(name) do
    Repo.insert(%Tokens{fullName: name})
    get_uuid(name)
  end
end

