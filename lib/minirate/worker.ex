defmodule Minirate.Worker do
  @moduledoc false

  use GenServer

  alias Minirate.Counter

  # Public API

  def start_link(mnesia_table, expiry_ms, cleanup_period_ms) do
    args = %{
      mnesia_table: mnesia_table,
      expiry_ms: expiry_ms,
      cleanup_period_ms: cleanup_period_ms
    }

    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  # GenServer Callbacks

  def init(args) do
    Process.send_after(self(), :create_table, 500)
    :timer.send_interval(args.cleanup_period_ms, :expire)

    {:ok, args}
  end

  def handle_info(:expire, state) do
    expiration = now() - state.expiry_ms
    Counter.expire_keys(state.mnesia_table, expiration)

    {:noreply, state}
  end

  def handle_info(:create_table, state) do
    Counter.create_mnesia_table(state.mnesia_table)
    {:noreply, state}
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end
end
