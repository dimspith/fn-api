defmodule FnApi.Database.Labelling do
  import Ecto.Query
  require Ecto.UUID
  alias FnApi.Database.{Repo, Labels, Tokens, Tags}
  
  def convert!("true"), do: true
  def convert!("false"), do: false
  def convert!(num), do: String.to_integer(num)

  defp valid_token?(token) do
    case Ecto.UUID.dump(token) do
      {:ok, token_bin} -> Repo.one(from(t in Tokens, select: t.uuid == ^token_bin))
      :error -> false
    end
  end

  defp get_tags(params) do
    Enum.filter(Map.keys(params), fn key ->
      String.starts_with?(key, "tag")
    end)
    |> Enum.map(&String.trim_leading(&1, "tag-"))
  end

  defp is_label_resubmission?(uuid, domain) do
    Repo.one(
      from(l in Labels,
        where: l.uuid == ^uuid and l.domain == ^domain
      )
    )
  end

  defp submit_label(params) do
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

  defp resubmit_label(uuid, previous_label, params) do
    updated_label =
      Ecto.Changeset.change(previous_label,
        isFake: convert!(params["is-fake"]),
        comments: params["comments"]
      )

    # Update label
    Repo.update!(updated_label)

    # Delete tags
    Repo.delete_all(from(t in Tags, where: t.uuid == ^uuid and t.domain == ^params["domain"]))
  end

  defp insert_tags(uuid, tags, params) do
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
  end

  def insert_label(params) do
    if(valid_token?(params["token"])) do
      domain = params["domain"]
      uuid = Ecto.UUID.dump!(params["token"])
      tags = get_tags(params)

      # If the domain was already submitted by the user, resubmit the current label
      case previous_label = is_label_resubmission?(uuid, domain) do
        nil -> submit_label(params)
        _  -> resubmit_label(uuid, previous_label, params)
      end

      insert_tags(uuid, tags, params)

      %{result: :success}
    else
      %{result: :failure, error: "Permission denied, invalid token!"}
    end
  end
end
