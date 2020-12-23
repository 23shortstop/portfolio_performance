use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :portfolio_performance, PortfolioPerformanceWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :error

config :portfolio_performance, marketstack_access_key: "test_token"

config :tesla, adapter: Tesla.Mock
