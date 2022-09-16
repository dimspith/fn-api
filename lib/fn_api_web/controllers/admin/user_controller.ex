defmodule FnApiWeb.Admin.UserController do
  @moduledoc """
  A set of functions to handle users in the database
  """

  import Ecto.Query
  alias FnApi.Database.{Repo, Tokens}
  use FnApiWeb, :controller

  defp get_user(name), do: Repo.one(from t in Tokens, where: t.fullName == ^name)

  defp user_to_map(user) do
    Map.take(user, [:fullName, :uuid])
    |> Map.update!(:uuid, &Ecto.UUID.load!(&1))
  end

  defp users_to_map(db_res), do: Enum.map(db_res, fn user -> user_to_map(user) end)
  ## Generate a map from a database response containing Tokens

  def create(conn, params) do
    ## Create a new user

    name = params["name"]

    if is_nil(name) do
      conn
      |> put_status(400)
      |> json(%{"error" => "No name supplied!"})
    else
      case get_user(name) do
        nil ->
          Repo.insert(%Tokens{fullName: name})
          json(conn, get_user(name) |> user_to_map())

        _ ->
          conn
          |> json(%{"error" => "A user with that name already exists!"})
      end
    end
  end

  def delete(conn, params) do
    ## Delete a user

    name = params["name"]

    if is_nil(name) do
      conn
      |> put_status(400)
      |> json(%{"error" => "No name supplied!"})
    else
      case get_user(name) do
        nil ->
          conn
          |> json(%{"error" => "No user with that name exists!"})

        user ->
          Repo.delete!(user)
          json(conn, %{"success" => "User deleted successfully!"})
      end
    end
  end

  def get(conn, params) do
    name = params["name"]

    if is_nil(name) do
      conn
      |> put_status(400)
      |> json(%{"error" => "No name supplied!"})
    else
      case get_user(name) do
        nil ->
          conn
          |> json(%{"error" => "No user with that name exists!"})

        user ->
          json(conn, user_to_map(user))
      end
    end
  end

  def get_all(conn, _params) do
    users =
      Repo.all(from(Tokens))
      |> users_to_map()

    json(conn, users)
  end
end
