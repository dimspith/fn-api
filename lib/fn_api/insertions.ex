defmodule FnApi.Insertions do
  use Ecto.Schema
  import Ecto.Changeset

  schema "insertions" do
    field :date, :integer
    field :domain, :string

    timestamps()
  end

  @doc false
  def changeset(insertions, attrs) do
    insertions
    |> cast(attrs, [:domain, :date])
    |> validate_required([:domain, :date])
  end
end
