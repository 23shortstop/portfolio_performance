# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :portfolio_performance, PortfolioPerformanceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HwbnQg53s7Cz9UWu4IH14NZXw1KdBKyXAAtOUEHen2QZQrilpxCgBxCv+75g3iRz",
  render_errors: [view: PortfolioPerformanceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PortfolioPerformance.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "J92s9u5lJiRsJjMJRdpIyIhP4+ZuMlA6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :portfolio_performance,
  marketstack_url: "https://api.marketstack.com/v1/",
  marketstack_access_key: System.get_env("MARKETSTACK_ACCESS_KEY")
