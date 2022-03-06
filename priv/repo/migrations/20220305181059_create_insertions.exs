defmodule FnApi.Repo.Migrations.CreateInsertions do
  use Ecto.Migration

  def change do
    create table(:insertions) do
      add :domain, :string
      add :date, :integer
    end
    create unique_index(:insertions, [:domain])
  end
end
