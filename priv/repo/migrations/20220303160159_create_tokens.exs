defmodule FnApi.Database.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :fullName, :string
    end
  end
end
