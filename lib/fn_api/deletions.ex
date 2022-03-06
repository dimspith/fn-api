defmodule FnApi.Deletions do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deletions" do
    field :date, :integer
    field :domain, :string
  end

  @doc false
  def changeset(deletions, attrs) do
    deletions
    |> cast(attrs, [:domain, :date])
    |> validate_required([:domain, :date])
    |> unique_constraint(:domain, name: :deletions_domain_index)
  end
end
