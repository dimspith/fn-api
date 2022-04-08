defmodule FnApi.Tokens do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key {:uuid, :binary_id, autogenerate: true}
  schema "tokens" do
    field :fullName, :string
  end

  @doc false
  def changeset(tokens, attrs) do
    tokens
    |> cast(attrs, [:fullName])
    |> validate_required([:fullName])
  end
end
