defmodule Minirate do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Minirate.Worker, [mnesia_table(), expiry_ms(), cleanup_period_ms()])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def check_limit(action, id, limit) do
    Minirate.Counter.check_limit(mnesia_table(), {action, id, limit, now()})
  end

  def check_limit(action, id, limit, increment) do
    Minirate.Counter.check_limit(mnesia_table(), {action, id, limit, now()}, increment)
  end

  defp expiry_ms, do: get_config(:expiry_ms)

  defp mnesia_table, do: get_config(:mnesia_table)

  defp cleanup_period_ms, do: get_config(:cleanup_period_ms)

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

  defp now do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end
end
