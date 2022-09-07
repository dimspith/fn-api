defmodule FnApi.Database.Labelling do
  import Ecto.Query
  import FnApi.Database.Utils
  require Ecto.UUID
  require Logger
  alias FnApi.Database.{Repo, Labels, Tags}

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

  defp submit_label(uuid, params) do
    Logger.debug("Submitting Label!")
    Repo.insert!(
      %Labels{
        # uuid: Ecto.UUID.dump!(params["token"]),
        uuid: uuid,
        domain: params["domain"],
        isFake: convert!(params["is-fake"]),
        comments: params["comments"]
      },
      returning: false
    )
  end

  defp resubmit_label(uuid, previous_label, params) do
    Logger.debug("Resubmitting Label!")
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
    if(uuid = valid_token?(params["token"])) do
      domain = params["domain"]
      
      tags = get_tags(params)

      # If the domain was already submitted by the user, resubmit the current label
      case previous_label = is_label_resubmission?(uuid, domain) do
        nil -> submit_label(uuid, params)
        _  -> resubmit_label(uuid, previous_label, params)
      end

      insert_tags(uuid, tags, params)

      %{result: :success}
    else
      %{result: :failure, error: "Permission denied, invalid token!"}
    end
  end
end
