defmodule PortfolioPerformanceWeb.PerformanceLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(PortfolioPerformanceWeb.PerformanceView, "performance.html", assigns)
  end

  def mount(_options, socket) do
    {:ok, socket}
  end

  def handle_event("build", portfolio_params, socket) do
    IO.inspect portfolio_params
    {:noreply, socket}
  end
end
