defmodule PortfolioPerformanceWeb.Router do
  use PortfolioPerformanceWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {PortfolioPerformanceWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PortfolioPerformanceWeb do
    pipe_through :browser

    live "/", PerformanceLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", PortfolioPerformanceWeb do
  #   pipe_through :api
  # end
end
