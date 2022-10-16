defmodule FnApiWeb.Admin.LabelController do
  use FnApiWeb, :controller
  require Logger
  alias FnApi.Database.{Repo, Labels, Tags}
  import Ecto.{Query, UUID}

  defp get_queries() do
    ## Get queries without filtering

    tags =
      from t in Tags,
        select: %{tag: t.tag, domain: t.domain, uuid: t.uuid}

    labels =
      from l in Labels,
        select: %{
          inserted_at: l.inserted_at,
          updated_at: l.updated_at,
          comments: l.comments,
          is_fake: l.isFake,
          domain: l.domain,
          uuid: l.uuid
        }

    %{labels: labels, tags: tags}
  end

  defp load_uuids(res) do
    Enum.map(
      res,
      &Map.update!(&1, :uuid, fn uuid ->
        load!(uuid)
      end)
    )
  end

  defp map_remove_keys(map, keys), do: Map.drop(map, keys)

  defp create_and_put_in(map, keys, val) do
    put_in(map, Enum.map(keys, &Access.key(&1, %{})), val)
  end

  defp append_tag_in(map, keys, val) do
    case get_in(map, keys) do
      nil -> put_in(map, Enum.map(keys, &Access.key(&1, %{})), [val])
      _ -> update_in(map, Enum.map(keys, &Access.key(&1, %{})), &[val | &1])
    end
  end

  defp labels_partition_by_uuid(labels) do
    Enum.reduce(labels, %{}, fn label, acc ->
      create_and_put_in(
        acc,
        [label[:uuid], label[:domain]],
        map_remove_keys(label, [:uuid, :domain])
      )
    end)
  end

  defp labels_merge_with_tags(labels, tags) do
    Enum.reduce(tags, labels, fn curr_tag, acc ->
      append_tag_in(
        acc,
        [curr_tag[:uuid], curr_tag[:domain], :tags],
        curr_tag[:tag]
      )
    end)
  end

  defp maps_merge_uuid(%{labels: labels, tags: tags}) do
    labels
    |> labels_partition_by_uuid
    |> labels_merge_with_tags(tags)
  end

  defp fetch_from_db(query), do: query |> Repo.all() |> load_uuids

  defp db_get_labels() do
    ## Get all labels grouped by uuid
    %{labels: labels_query, tags: tags_query} = get_queries()
    maps_merge_uuid(%{labels: fetch_from_db(labels_query), tags: fetch_from_db(tags_query)})
  end

  def get_labels(conn, _params) do
    json(conn, db_get_labels())
  end
end
