defmodule FnApi.Database.Checkpoints do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checkpoints" do
    field :date, :integer
  end

  @doc false
  def changeset(checkpoints, attrs) do
    checkpoints
    |> cast(attrs, [:date])
    |> validate_required([:date])
  end
end
