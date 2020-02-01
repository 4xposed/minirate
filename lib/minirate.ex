defmodule Minirate do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    mnesia_table = get_config(:mnesia_table)
    expiry_ms = get_config(:expiry_ms)
    cleanup_period_ms = get_config(:cleanup_period_ms)

    children = [
      worker(Minirate.Worker, [mnesia_table, expiry_ms, cleanup_period_ms])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def check_limit(action, id, limit) do
    Minirate.Worker.check_limit(action, id, limit)
  end

  defp get_config(key) do
    case Application.get_env(:minirate, key) do
      nil ->
        Kernel.raise(
          ArgumentError,
          "the configuration parameter #{Kernel.inspect(key)} is not set"
        )

      value ->
        value
    end
  end
end
