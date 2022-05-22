defmodule FnApi.Database.Labels do
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key {:uuid, :binary_id, autogenerate: true}
  schema "labels" do
    field :uuid, :binary_id
    field :domain, :string
    field :isFake, :boolean
    field :comments, :string

    timestamps()
  end

  @doc false
  def changeset(label, attrs) do
    label
    |> cast(attrs, [:uuid, :domain, :isFake, :comments])
    |> validate_required([:uuid, :domain, :isFake, :comments])
  end
end
