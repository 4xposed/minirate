import Config

config :minirate,
  mnesia_table: :rate_limiter,
  expiry_ms: 300,
  cleanup_period_ms: 50
