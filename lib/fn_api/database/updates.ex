defmodule FnApi.Database.Updates do
  import Ecto.Query
  require Logger
  alias FnApi.Database.{Repo, Insertions, Deletions, Checkpoints}

  def blacklist_file do
    case System.get_env("FNAPI_BLACKLIST") do
      nil -> Application.app_dir(:fn_api, "priv") <> "/blacklist"
      blacklist -> blacklist
    end
  end

  defp get_curr_unix_time(), do: DateTime.now!("Etc/UTC") |> DateTime.to_unix()

  defp db_add_changes(changes, datetime) do
    ## Add changes (insertions/deletions to database)

    # Add all changes to Insertions table
    Enum.each(changes["insert"], fn x ->
      changes =
        %Insertions{}
        |> Insertions.changeset(%{domain: x, date: datetime})

      case Repo.insert(changes) do
        {:ok, _} -> nil
        {:error, _} -> Logger.error("Failed to add domain '#{x}' to Insertions!")
      end
    end)

    # Add all changes to Deletions table
    Enum.each(changes["delete"], fn x ->
      changes =
        %Deletions{}
        |> Deletions.changeset(%{domain: x, date: datetime})

      case Repo.insert(changes) do
        {:ok, _} -> nil
        {:error, _} -> Logger.error("Failed to add domain '#{x}' to Deletions!")
      end
    end)
  end

  defp db_add_checkpoint(datetime), do: Repo.insert(%Checkpoints{date: datetime})
  ## Add current unix time as a checkpoint

  def db_add_all(changes) do
    ## Add changes and checkpoint to database
    datetime = get_curr_unix_time()
    db_add_changes(changes, datetime)
    db_add_checkpoint(datetime)
    {:ok, :success}
  end

  defp diff_find_common(diff, list, type) do
    ## Find common elements between a key from the diff and a list

    MapSet.intersection(
      MapSet.new(list),
      MapSet.new(diff[type])
    )
    |> MapSet.to_list()
  end

  defp diff_update_insertions(diff, insertions, common) do
    ## Append insertions to diff, removing common elements from both
    ## appended insertions and stored deletions.

    diff
    |> Map.update!(:insert, fn current ->
      current ++ (insertions -- common)
    end)
    |> Map.update!(:delete, fn current ->
      current -- common
    end)
  end

  defp diff_update_deletions(diff, deletions, common) do
    ## Append deletions to diff, removing common elements from both
    ## appended deletions and stored insertions.
    diff
    |> Map.update!(:delete, fn current ->
      current ++ (deletions -- common)
    end)
    |> Map.update!(:insert, fn current ->
      current -- common
    end)
  end

  defp diff_insert_dedup(diff, [], _), do: diff

  defp diff_insert_dedup(diff, changes, type) do
    ## Add domain insertions and deletions to the diff, removing mutually exclusive changes.

    case type do
      :insert ->
        common = diff_find_common(diff, changes, :delete)
        diff_update_insertions(diff, changes, common)

      :delete ->
        common = diff_find_common(diff, changes, :insert)
        diff_update_deletions(diff, changes, common)
    end
  end

  defp get_sorted_tables() do
    ## Get the contents of the checkpoints, insertions, and deletions tables sorted by date.
    checkpoints = Repo.all(from(c in Checkpoints, select: c.date, order_by: c.date))

    insertions =
      Repo.all(from(i in Insertions, select: {i.domain, i.date}, order_by: i.date))
      |> Enum.group_by(&elem(&1, 1))

    deletions =
      Repo.all(from(d in Deletions, select: {d.domain, d.date}, order_by: d.date))
      |> Enum.group_by(&elem(&1, 1))

    {checkpoints, insertions, deletions}
  end

  defp get_sorted_tables(start_date) do
    ## Get the contents of the checkpoints, insertions, and deletions tables sorted by date
    ## starting from the supplied `start_date`
    checkpoints =
      Repo.all(
        from(c in Checkpoints, select: c.date, where: c.date > ^start_date, order_by: c.date)
      )

    insertions =
      Repo.all(
        from(i in Insertions,
          select: {i.domain, i.date},
          where: i.date > ^start_date,
          order_by: i.date
        )
      )
      |> Enum.group_by(&elem(&1, 1))

    deletions =
      Repo.all(
        from(d in Deletions,
          select: {d.domain, d.date},
          where: d.date > ^start_date,
          order_by: d.date
        )
      )
      |> Enum.group_by(&elem(&1, 1))

    {checkpoints, insertions, deletions}
  end

  defp remove_redundant([], _, _), do: []
  defp remove_redundant(nil, _, _), do: []

  defp remove_redundant(changes, diff, type) do
    ## Remove already existing domains from current changes
    (changes |> Enum.map(&elem(&1, 0))) -- diff[type]
  end

  defp construct_diff(tables) do
    ## Construct the diff
    {checkpoints, insertions, deletions} = tables

    Enum.reduce(checkpoints, %{insert: [], delete: []}, fn checkpoint, diff ->
      to_insert = insertions[checkpoint] |> remove_redundant(diff, :insert)
      to_delete = deletions[checkpoint] |> remove_redundant(diff, :delete)

      diff
      |> diff_insert_dedup(to_insert, :insert)
      |> diff_insert_dedup(to_delete, :delete)
    end)
  end

  defp sort_diff(diff) do
    ## Sort diff values
    diff
    |> Map.update!(:insert, &Enum.sort/1)
    |> Map.update!(:delete, &Enum.sort/1)
  end

  def update_blacklist_file() do
    ## Generate the whole blacklist and write it to a file.

    diff =
      get_sorted_tables()
      |> construct_diff()
      |> sort_diff()

    File.write!(
      blacklist_file(),
      diff[:insert]
      |> Enum.map(fn x -> x <> "\n" end)
    )

    Logger.debug("Updated blacklist file!")
  end

  def generate_diff(date) do
    ## Generate the diff starting from `date`.

    get_sorted_tables(date)
    |> construct_diff()
    |> sort_diff()
  end

  def get_last_update() do
    ## Get the last update time from the database.

    lastupdate = Repo.all(from c in Checkpoints, select: max(c.date))

    case lastupdate do
      nil -> 0
      _ -> hd(lastupdate)
    end
  end
end
