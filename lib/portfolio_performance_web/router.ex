defmodule PortfolioPerformanceWeb.Router do
  use PortfolioPerformanceWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PortfolioPerformanceWeb do
    pipe_through :browser

    live "/", PageController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PortfolioPerformanceWeb do
  #   pipe_through :api
  # end
end
