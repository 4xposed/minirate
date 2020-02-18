defmodule Minirate.WorkerTest do
  use ExUnit.Case

  alias Minirate.Worker

  setup do
    :mnesia.create_table(:rate_limiter, attributes: [:key, :count, :timestamp])

    on_exit(fn -> :mnesia.delete_table(:rate_limiter) end)
  end

  describe ".expire" do
    test "removes from the mnesia table the expired counters" do
      time_in_ms = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
      old_timestamp = time_in_ms - 100_000

      :mnesia.dirty_write({:rate_limiter, "test_1", 2, old_timestamp})
      :mnesia.dirty_write({:rate_limiter, "test_2", 4, time_in_ms})

      Task.async(fn ->
        Kernel.send(Worker, :expire)
        Process.sleep(10)
      end)
      |> Task.await(:infinity)

      assert [] == :mnesia.dirty_match_object({:rate_limiter, "test_1", :_, :_})

      assert [{:rate_limiter, "test_2", 4, time_in_ms}] ==
               :mnesia.dirty_match_object({:rate_limiter, "test_2", :_, :_})
    end
  end
end
