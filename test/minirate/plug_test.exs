defmodule Minirate.PlugTest do
  use ExUnit.Case
  import Plug.Test

  alias Minirate.Plug

  setup do
    :mnesia.create_table(:rate_limiter, attributes: [:key, :count, :timestamp])

    on_exit(fn -> :mnesia.delete_table(:rate_limiter) end)
  end

  test "rate limits requests" do
    req_conn =
      conn(:get, "/", [])
      |> Map.put(:remote_ip, {0, 0, 0, 0})

    conn = Plug.call(req_conn, action: "device_request", limit: 2)
    refute conn.halted

    conn = Plug.call(req_conn, action: "device_request", limit: 2)
    refute conn.halted

    conn = Plug.call(req_conn, action: "device_request", limit: 2)
    assert conn.halted
    assert conn.status == 429
  end

  test "resets limit with time" do
    req_conn =
      conn(:get, "/", [])
      |> Map.put(:remote_ip, {0, 0, 0, 0})

    conn = Plug.call(req_conn, action: "device_request", limit: 2)
    refute conn.halted

    conn = Plug.call(req_conn, action: "device_request", limit: 2)
    refute conn.halted

    conn = Plug.call(req_conn, action: "device_request", limit: 2)
    assert conn.halted
    assert conn.status == 429

    Process.sleep(400)

    conn = Plug.call(req_conn, action: "device_request", limit: 2)
    refute conn.halted
  end
end
