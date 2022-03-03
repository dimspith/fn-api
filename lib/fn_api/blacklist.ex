defmodule FnApi.Blacklist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "list" do
    field :domain, :string

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:domain])
    |> validate_required([:domain])
  end
end
