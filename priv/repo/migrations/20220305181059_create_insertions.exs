defmodule FnApi.Database.Repo.Migrations.CreateInsertions do
  use Ecto.Migration

  def change do
    create table(:insertions) do
      add :domain, :string
      add :date, :integer
    end
  end
end
