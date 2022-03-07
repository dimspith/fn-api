defmodule FnApi.Repo.Migrations.CreateCheckpoints do
  use Ecto.Migration

  def change do
    create table(:checkpoints) do
      add :date, :integer
    end
  end
end
