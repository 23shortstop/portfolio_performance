defmodule PortfolioPerformanceWeb.PageController do
  use PortfolioPerformanceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
