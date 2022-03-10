defmodule FnApi.Utils do
  import Ecto.Query
  alias FnApi.{Repo, Insertions, Deletions, Checkpoints}

  def fetch_changes(path) do
    ## Fetch all changes from a file and commit to DB
    file = File.read!(path)

    # If file is empty don't do anything
    if(file == "") do
      {:error, "file is empty"}
    else
      # Read file into a map
      lines =
        file
        |> String.split("\n")
        |> Enum.map(fn x -> String.split(x, " ") end)

      changes =
        Enum.reduce(lines, %{add: [], rm: []}, fn x, acc ->
          case Enum.at(x, 0) do
            "+" -> Map.update!(acc, :add, &[Enum.at(x, 1) | &1])
            "-" -> Map.update!(acc, :rm, &[Enum.at(x, 1) | &1])
            _ -> acc
          end
        end)

      # Insert checkpoint to DB
      datetime = DateTime.now!("Etc/UTC") |> DateTime.to_unix()
      Repo.insert(%Checkpoints{date: datetime})

      # Add all changes to Insertions table
      Enum.map(Map.fetch!(changes, :add), fn x ->
        changes =
          %Insertions{}
          |> Insertions.changeset(%{domain: x, date: datetime})

        case Repo.insert(changes) do
          {:ok, _} -> IO.puts("Insertion successful!")
          {:error, _} -> IO.puts("Error: Insertion failed!")
        end
      end)

      # Add all changes to Deletions table
      Enum.each(Map.fetch!(changes, :rm), fn x ->
        changes =
          %Deletions{}
          |> Deletions.changeset(%{domain: x, date: datetime})

        case Repo.insert(changes) do
          {:ok, _} -> IO.puts("Insertion successful!")
          {:error, _} -> IO.puts("Error: Insertion failed!")
        end
      end)

      {:ok, :success}
    end
  end


  def insert_dedup(diff, to_insert, :insertions) do
    ## Find common elements between current insertions and stored deletions

    unless(Enum.empty?(to_insert)) do
      common =
        MapSet.intersection(
          MapSet.new(to_insert),
          MapSet.new(Map.get(diff, :deletions))
        )
        |> MapSet.to_list()

      # Delete common elements from current insertions, stored deletions and insert to diff
      diff
      |> Map.update!(:insertions, fn curr_inserted ->
        curr_inserted ++ (to_insert -- common)
      end)
      |> Map.update!(:deletions, fn curr_deleted ->
        curr_deleted -- common
      end)
    else
      diff
    end
  end

  def insert_dedup(diff, to_delete, :deletions) do
    ## Find common elements between current deletions and stored insertions

    unless(Enum.empty?(to_delete)) do
      common =
        MapSet.intersection(
          MapSet.new(to_delete),
          MapSet.new(Map.get(diff, :insertions))
        )
        |> MapSet.to_list()

      # Delete common elements from current deletions, stored insertions and insert to diff
      diff
      |> Map.update!(:deletions, fn curr_deleted ->
        curr_deleted ++ (to_delete -- common)
      end)
      |> Map.update!(:insertions, fn curr_inserted ->
        curr_inserted -- common
      end)      
    else
      diff
    end
  end

  def generate_diff() do
    checkpoints = Repo.all(from(c in Checkpoints, select: c.date, order_by: c.date))

    insertions =
      Repo.all(from(i in Insertions, select: {i.domain, i.date}, order_by: i.date))
      |> Enum.group_by(&elem(&1, 1))

    deletions =
      Repo.all(from(d in Deletions, select: {d.domain, d.date}, order_by: d.date))
      |> Enum.group_by(&elem(&1, 1))

    diff =
      Enum.reduce(checkpoints, %{insertions: [], deletions: []}, fn date, diff ->
        to_insert = insertions[date]
        to_delete = deletions[date]

        diff =
          case to_insert do
            nil ->
              diff

            _ ->
              insert_dedup(
                diff,
                to_insert
                |> Enum.map(&elem(&1, 0))
                |> IO.inspect(label: "Insert:")
                |> Kernel.--(diff[:insertions]),
                :insertions
              )
          end
          case to_delete do
            nil ->
              diff

            _ ->
              insert_dedup(
                diff,
                to_delete
                |> Enum.map(&elem(&1, 0))
                |> IO.inspect(label: "Delete:")
                |> Kernel.--(diff[:deletions]),
                :deletions
              )
          end
      end)

    File.write!(
      "priv/lists/blacklist",
      diff[:insertions] |> Enum.map(fn x -> x <> "\n" end)
    )
  end

  def generate_diff(date) do
    checkpoints =
      Repo.all(from(c in Checkpoints, select: c.date, where: c.date > ^date, order_by: c.date))

    insertions =
      Repo.all(
        from(i in Insertions, select: {i.domain, i.date}, where: i.date > ^date, order_by: i.date)
      )
      |> Enum.group_by(&elem(&1, 1))

    deletions =
      Repo.all(
        from(d in Deletions, select: {d.domain, d.date}, where: d.date > ^date, order_by: d.date)
      )
      |> Enum.group_by(&elem(&1, 1))

    Enum.reduce(checkpoints, %{insertions: [], deletions: []}, fn date, diff ->
      to_insert = insertions[date]
      to_delete = deletions[date]

      diff =
        case to_insert do
          nil ->
            diff

          _ ->
            insert_dedup(
              diff,
              to_insert
              |> Enum.map(&elem(&1, 0))
              |> IO.inspect(label: "Insert (date):")
              |> Kernel.--(diff[:insertions]),
              :insertions
            )
        end

      diff =
        case to_delete do
          nil ->
            diff

          _ ->
            insert_dedup(
              diff,
              to_delete
              |> Enum.map(&elem(&1, 0))
              |> IO.inspect(label: "Delete (date):")
              |> Kernel.--(diff[:deletions]),
              :deletions
            )
        end

      diff
    end)
  end

  def get_last_update() do
    lastupdate = Repo.all(from c in Checkpoints, select: max(c.date))

    case lastupdate do
      nil -> 0
      _ -> lastupdate
    end
  end
end
