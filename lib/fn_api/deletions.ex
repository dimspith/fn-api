defmodule FnApi.Deletions do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deletions" do
    field :date, :integer
    field :domain, :string

    timestamps()
  end

  @doc false
  def changeset(deletions, attrs) do
    deletions
    |> cast(attrs, [:domain, :date])
    |> validate_required([:domain, :date])
  end
end
