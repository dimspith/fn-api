defmodule FnApi.Database.Utils do
  @moduledoc """
  Utility functions
  """

  import Ecto.Query
  require Ecto.UUID
  require Logger
  alias FnApi.Database.{Repo, Tokens}

  def convert!("true"), do: true
  def convert!("false"), do: false
  def convert!(num), do: String.to_integer(num)

  def valid_uuid?(uuid) do
    case Ecto.UUID.dump(uuid) do
      {:ok, binary} -> binary
      :error -> false
    end
  end

  def token_exists?(token) do
    case Repo.exists?(from(t in Tokens, select: t.uuid == ^token)) do
      true -> token
      false -> false
    end
  end

  def valid_token?(token) do
    token_binary = valid_uuid?(token)
    if token_binary && token_exists?(token_binary), do: token_binary, else: false
  end
end
