defmodule FnApi.Database.Repo.Migrations.CreateLabels do
  use Ecto.Migration

  def change do
    create table(:labels) do
      add :uuid, :uuid
      add :domain, :string
      add :isFake, :boolean, default: false, null: false
      add :comments, :string

      timestamps()
    end
  end
end
