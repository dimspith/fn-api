defmodule FnApi.Labelling do
  import Ecto.Query
  require Ecto.UUID
  alias FnApi.Database.{Repo, Labels, Tokens, Tags}

  def convert!("true"), do: true
  def convert!("false"), do: false
  def convert!(num), do: String.to_integer(num)

  def valid_token?(token) do
    case Ecto.UUID.dump(token) do
      {:ok, token_bin} -> Repo.one(from(t in Tokens, select: t.uuid == ^token_bin))
      :error -> false
    end
  end
  
  def db_insert_label(params) do
    if(valid_token?(params["token"])) do
      uuid = Ecto.UUID.dump!(params["token"])

      tags =
        Enum.filter(Map.keys(params), fn key ->
          String.starts_with?(key, "tag")
        end)
        |> Enum.map(&String.trim_leading(&1, "tag-"))

      # Check if user has submitted this domain in the past
      last_label =
        Repo.one(
          from(l in Labels,
            where: l.uuid == ^uuid and l.domain == ^params["domain"]
          )
        )

      # If the domain was already submitted by the user, replace the current label
      if(last_label) do
        # Update label
        updated_label =
          Ecto.Changeset.change(last_label,
            isFake: convert!(params["is-fake"]),
            comments: params["comments"]
          )

        Repo.update!(updated_label)

        # Delete tags
        Repo.delete_all(from(t in Tags, where: t.uuid == ^uuid and t.domain == ^params["domain"]))
      else
        # Insert label
        Repo.insert!(
          %Labels{
            uuid: Ecto.UUID.dump!(params["token"]),
            domain: params["domain"],
            isFake: convert!(params["is-fake"]),
            comments: params["comments"]
          },
          returning: false
        )
      end

      # Insert Tags
      if(!Enum.empty?(tags)) do
        Enum.each(tags, fn tag ->
          Repo.insert!(
            %Tags{
              uuid: uuid,
              domain: params["domain"],
              tag: tag
            },
            returning: false
          )
        end)
      end

      if(params["bias"]) do
        Repo.insert!(%Tags{
          uuid: uuid,
          domain: params["domain"],
          tag: params["bias"]
        })
      end

      %{result: :success}
    else
      %{result: :failure, error: "Permission denied, invalid token!"}
    end
  end
end
