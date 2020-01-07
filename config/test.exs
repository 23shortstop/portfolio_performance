use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :portfolio_performance, PortfolioPerformanceWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :portfolio_performance, world_trading_token: "test_token"
