defmodule MinirateTest do
  use ExUnit.Case

  setup do
    :mnesia.create_table(:rate_limiter, attributes: [:key, :count, :timestamp])

    on_exit(fn -> :mnesia.delete_table(:rate_limiter) end)
  end

  describe ".check_limit/3" do
    test "increments the counter" do
      assert {:allow, 1} == Minirate.check_limit("test", "user_1", 10)
      assert {:allow, 2} == Minirate.check_limit("test", "user_1", 10)
      assert {:allow, 1} == Minirate.check_limit("test", "user_2", 10)
    end

    test "returns a a tuple with value {:block, :limit_exceeded} when the limit is reached" do
      assert {:allow, 1} == Minirate.check_limit("test", "user_1", 2)
      assert {:allow, 2} == Minirate.check_limit("test", "user_1", 2)
      assert {:allow, 1} == Minirate.check_limit("test", "user_2", 2)
      assert {:block, :limit_exceeded} == Minirate.check_limit("test", "user_1", 2)
    end

    test "counter is reset after expiration" do
      assert {:allow, 1} == Minirate.check_limit("test", "user_1", 2)
      assert {:allow, 2} == Minirate.check_limit("test", "user_1", 2)
      assert {:block, :limit_exceeded} == Minirate.check_limit("test", "user_1", 2)

      Process.sleep(400)

      assert {:allow, 1} == Minirate.check_limit("test", "user_1", 2)
    end
  end

  describe ".check_limit/4" do
    test "increments the counter with a custom increment" do
      assert {:allow, 5} == Minirate.check_limit("test", "user_1", 10, 5)
      assert {:allow, 8} == Minirate.check_limit("test", "user_1", 10, 3)
      assert {:allow, 9} == Minirate.check_limit("test", "user_2", 10, 9)
    end

    test "returns a a tuple with value {:block, :limit_exceeded} when the limit is reached" do
      assert {:allow, 2} == Minirate.check_limit("test", "user_1", 2, 2)
      assert {:allow, 1} == Minirate.check_limit("test", "user_2", 2, 1)
      assert {:block, :limit_exceeded} == Minirate.check_limit("test", "user_1", 2, 2)
    end

    test "counter is reset after expiration" do
      assert {:allow, 2} == Minirate.check_limit("test", "user_1", 2, 2)
      assert {:block, :limit_exceeded} == Minirate.check_limit("test", "user_1", 2, 2)

      Process.sleep(400)

      assert {:allow, 2} == Minirate.check_limit("test", "user_1", 2, 2)
    end
  end
end
