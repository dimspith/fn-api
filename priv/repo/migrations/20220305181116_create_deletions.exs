defmodule FnApi.Database.Repo.Migrations.CreateDeletions do
  use Ecto.Migration

  def change do
    create table(:deletions) do
      add :domain, :string
      add :date, :integer
    end
  end
end
