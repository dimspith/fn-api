defmodule FnApi.Database.Updates do
  import Ecto.Query
  require Logger
  alias FnApi.Database.{Repo, Insertions, Deletions, Checkpoints}

  defp read_changes(path) do
    case File.read!(path) do
      "" ->
        {:error, "File is Empty!"}

      file ->
        changes =
          file
          |> String.split("\n")
          |> Enum.map(fn x -> String.split(x, " ") end)
          |> Enum.reduce(%{add: [], rm: []}, fn x, acc ->
            case Enum.at(x, 0) do
              "+" -> Map.update!(acc, :add, &[Enum.at(x, 1) | &1])
              "-" -> Map.update!(acc, :rm, &[Enum.at(x, 1) | &1])
              _ -> acc
            end
          end)

        {:ok, changes}
    end
  end

  defp get_unix_time(), do: DateTime.now!("Etc/UTC") |> DateTime.to_unix()

  defp add_changes(changes, datetime) do
    # Add all changes to Insertions table
    Enum.map(changes[:add], fn x ->
      changes =
        %Insertions{}
        |> Insertions.changeset(%{domain: x, date: datetime})

      case Repo.insert(changes) do
        {:ok, _} -> nil
        {:error, _} -> Logger.error("Failed to add domain '#{x}' to Insertions!")
      end
    end)

    # Add all changes to Deletions table
    Enum.each(changes[:rm], fn x ->
      changes =
        %Deletions{}
        |> Deletions.changeset(%{domain: x, date: datetime})

      case Repo.insert(changes) do
        {:ok, _} -> nil
        {:error, _} -> Logger.error("Failed to add domain '#{x}' to Deletions!")
      end
    end)
  end

  defp add_checkpoint(datetime), do: Repo.insert(%Checkpoints{date: datetime})

  def insert_changes(path) do
    case read_changes(path) do
      {:error, msg} ->
        {:error, msg}

      {:ok, changes} ->
        datetime = get_unix_time()
        add_changes(changes, datetime)
        add_checkpoint(datetime)
        {:ok, :success}
    end
  end

  defp diff_find_common(diff, list, type) do
    MapSet.intersection(
      MapSet.new(list),
      MapSet.new(diff[type]))
    |> MapSet.to_list()
    |> IO.inspect(label: "Common")
  end

  defp diff_update_insertions(diff, insertions, common) do
    diff
    |> Map.update!(:insertions, fn current ->
      current ++ (insertions -- common)
    end)
    |> Map.update!(:deletions, fn current ->
      current -- common
    end)
    |> IO.inspect(label: "DAI")
  end

  defp diff_update_deletions(diff, deletions, common) do
    diff
    |> Map.update!(:deletions, fn current ->
      current ++ (deletions -- common)
    end)
    |> Map.update!(:insertions, fn current ->
      current -- common
    end)
    |> IO.inspect(label: "DAD")
  end

  defp diff_insert_dedup(diff, [], _), do: diff

  defp diff_insert_dedup(diff, changes, type) do
    ## Add domain insertions and deletions to the diff, removing mutually exclusive changes.

    case type do
      :insertions ->
        common = diff_find_common(diff, changes, :deletions)
        diff_update_insertions(diff, changes, common)
      :deletions ->
        common = diff_find_common(diff, changes, :insertions)
        diff_update_deletions(diff, changes, common)
    end
  end

  defp get_sorted_tables() do
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
    (changes |> Enum.map(&elem(&1, 0))) -- diff[type]
  end

  defp construct_diff(tables) do
    {checkpoints, insertions, deletions} = tables

    Enum.reduce(checkpoints, %{insertions: [], deletions: []}, fn checkpoint, diff ->
      to_insert = insertions[checkpoint] |> remove_redundant(diff, :insertions)
      to_delete = deletions[checkpoint] |> remove_redundant(diff, :deletions)

      diff
      |> diff_insert_dedup(to_insert, :insertions)
      |> diff_insert_dedup(to_delete, :deletions)
    end)
  end

  defp sort_diff(diff) do
    diff
    |> Map.update!(:insertions, &Enum.sort/1)
    |> Map.update!(:deletions, &Enum.sort/1)
  end

  def update_blacklist_file() do
    ## Generates the whole blacklist and writes to file.

    diff =
      get_sorted_tables()
      |> construct_diff()
      |> sort_diff()

    File.write!(
      "priv/lists/blacklist",
      diff[:insertions]
      |> Enum.map(fn x -> x <> "\n" end)
    )
    Logger.debug("Updated blacklist file!")
  end

  def generate_diff(date) do
    ## Generates the diffs from the blacklist at `date` to the current one.
    ## Returns the total `insertions`, `deletions` and the `lastupdate` as a Map.

    get_sorted_tables(date)
    |> construct_diff()
    |> sort_diff()
  end

  def get_last_update() do
    ## Gets the last update time from the database.

    lastupdate = Repo.all(from c in Checkpoints, select: max(c.date))

    case lastupdate do
      nil -> 0
      _ -> hd(lastupdate)
    end
  end
end
