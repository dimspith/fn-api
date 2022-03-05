defmodule FnApi.Repo.Migrations.CreateInsertions do
  use Ecto.Migration

  def change do
    create table(:insertions) do
      add :domain, :string
      add :date, :integer

      timestamps()
    end
  end
end
