defmodule FnApi.Repo.Migrations.CreateList do
  use Ecto.Migration

  def change do
    create table(:list) do
      add :domain, :string

      timestamps()
    end
  end
end
