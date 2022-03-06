defmodule FnApi.Repo.Migrations.CreateDeletions do
  use Ecto.Migration

  def change do
    create table(:deletions) do
      add :domain, :string
      add :date, :integer
    end
    create unique_index(:deletions, [:domain])
  end
end
