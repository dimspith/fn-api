defmodule FnApi.Database.Tags do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :uuid, :binary_id
    field :domain, :string
    field :tag, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:uuid, :domain, :tag])
    |> validate_required([:uuid, :domain, :tag])
  end
end
