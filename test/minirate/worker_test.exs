defmodule Minirate.WorkerTest do
  use ExUnit.Case

  alias Minirate.Worker

  setup do
    :mnesia.create_table(:rate_limiter, attributes: [:key, :count, :timestamp])

    on_exit(fn -> :mnesia.delete_table(:rate_limiter) end)
  end

  describe ".check_limit/3" do
    test "increments the counter" do
      assert {:allow, 1} == Worker.check_limit("test", "user_1", 10)
      assert {:allow, 2} == Worker.check_limit("test", "user_1", 10)
      assert {:allow, 1} == Worker.check_limit("test", "user_2", 10)
    end

    test "returns a a tuple with value {:block, :limit_exceeded} when the limit is reached" do
      assert {:allow, 1} == Worker.check_limit("test", "user_1", 2)
      assert {:allow, 2} == Worker.check_limit("test", "user_1", 2)
      assert {:allow, 1} == Worker.check_limit("test", "user_2", 2)
      assert {:block, :limit_exceeded} == Worker.check_limit("test", "user_1", 2)
    end

    test "counter is reset after expiration" do
      assert {:allow, 1} == Worker.check_limit("test", "user_1", 2)
      assert {:allow, 2} == Worker.check_limit("test", "user_1", 2)
      assert {:block, :limit_exceeded} == Worker.check_limit("test", "user_1", 2)

      Process.sleep 400

      assert {:allow, 1} == Worker.check_limit("test", "user_1", 2)
    end
  end
end
