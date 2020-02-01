use Mix.Config

config :minirate,
  mnesia_table: :rate_limiter,
  expiry_ms: 60_000,
  cleanup_period_ms: 10_000
