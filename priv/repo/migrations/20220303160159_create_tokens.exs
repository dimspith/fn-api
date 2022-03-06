defmodule FnApi.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :token, :string
      add :fullName, :string
    end
    create unique_index(:tokens, [:token])
  end
end
