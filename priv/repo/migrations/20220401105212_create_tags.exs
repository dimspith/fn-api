defmodule FnApi.Database.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :uuid, :uuid
      add :domain, :string
      add :tag, :string

      timestamps()
    end
  end
end
