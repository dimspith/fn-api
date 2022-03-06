defmodule FnApi.Tokens do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :fullName, :string
    field :token, :string
  end

  @doc false
  def changeset(tokens, attrs) do
    tokens
    |> cast(attrs, [:token, :fullName])
    |> validate_required([:token, :fullName])
    |> unique_constraint([:token])
  end
end
