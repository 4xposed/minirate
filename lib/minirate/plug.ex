defmodule Minirate.Plug do
  @moduledoc false

  import Plug.Conn

  alias Minirate

  def init, do: []

  def init(opts) do
    Enum.each([:action, :limit], fn key ->
      option = Keyword.get(opts, key)

      if Kernel.is_nil(option) do
        raise(
          ArgumentError,
          "Minirate.Plug requires the option #{Kernel.inspect(key)} to be set."
        )
      end
    end)

    opts
  end

  def call(conn, action: action, limit: limit) do
    ip = fetch_ip(conn)
    process(conn, action, limit, ip)
  end

  def call(conn, _), do: conn

  def process(conn, _action, _limit, ip) when is_nil(ip) do
    conn
  end

  def process(conn, action, limit, ip) do
    case Minirate.check_limit(action, ip, limit) do
      {:allow, _} -> conn
      {:skip, _} -> conn
      {:block, :limit_exceeded} -> block_request(conn)
    end
  end

  defp block_request(conn) do
    conn
    |> send_resp(429, "Too Many Requests")
    |> halt()
  end

  defp fetch_ip(conn) do
    conn.remote_ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end
end
