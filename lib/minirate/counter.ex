defmodule Minirate.Counter do
  @moduledoc false

  alias :mnesia, as: Mnesia

  @default_increment 1
  @mnesia_table Application.get_env(:minirate, :mnesia_table)

  def check_limit(action, id, limit, now) do
    check_limit(action, id, limit, now, @default_increment)
  end

  def check_limit(action, id, limit, now, increment) do
    with {:ok, count} <- get_count(action, id, now, increment),
         true <- (count <= limit) do
      {:allow, count}
    else
      false -> {:block, :limit_exceeded}
      {:error, reason} -> {:skip, reason}
      _ -> {:skip, :something_failed}
    end
  end

  def get_count(action, id, now) do
    get_count(action, id, now, @default_increment)
  end

  def get_count(action, id, now, increment) do
    table = @mnesia_table
    key = "#{action}_#{id}"

    transac_fn = fn ->
      case Mnesia.read({table, key}) do
        # No existing count found
        [] ->
          # Create count entry
          Mnesia.write({table, key, increment, now})
          {:ok, increment}

        # Count entry has been found
        [{^table, ^key, count, timestamp}] ->
          # Increment count
          current_count = count + increment
          Mnesia.write({table, key, current_count, timestamp})
          {:ok, current_count}
      end
    end

    case Mnesia.transaction(transac_fn) do
      {:atomic, {:ok, count}} -> {:ok, count}
      {:aborted, reason} -> {:error, reason}
    end
  end

  def expire_keys(time_of_expiration) do
    table = @mnesia_table

    transac_fn = fn ->
      match = {table, :"$1", :_, :"$2"}
      filter = [{:or, {:<, :"$2", time_of_expiration}, {:==, :"$2", time_of_expiration}}]
      result = [:"$1"]

      search_term = {match, filter, result}

      Mnesia.select(table, [search_term])
      |> Enum.each(fn key ->
        Mnesia.delete(table, key, :write)
      end)
    end

    case Mnesia.transaction(transac_fn) do
      {:atomic, :ok} -> :ok
      {:aborted, reason} -> :error
    end
  end

  def create_mnesia_table do
    Mnesia.create_table(@mnesia_table, attributes: [:key, :count, :timestamp])
  end
end
