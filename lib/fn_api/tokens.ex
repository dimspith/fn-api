defmodule FnApi.Tokens do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(tokens, attrs) do
    tokens
    |> cast(attrs, [:token])
    |> validate_required([:token])
  end
end
