defmodule PortfolioPerformanceWeb.PerformanceLive do
  use Phoenix.LiveView
  alias PortfolioPerformance.{Performance, TimexHelper}
  alias Phoenix.LiveView.Socket
  require Logger

  def mount(_options, _session, socket) do
    {:ok,
     socket
     |> assign(
       validation_errors: %{},
       performance: %{},
       input_params: %{},
       parsed_params: %{},
       notifications: %{}
     )}
  end

  def render(assigns) do
    Phoenix.View.render(PortfolioPerformanceWeb.PerformanceView, "performance.html", assigns)
  end

  def handle_event("build", portfolio_params, socket) do
    try do
      socket_state =
        socket
        |> clear_notifications
        |> parse_params(portfolio_params)
        |> validate_params
        |> build_performance

      {:noreply, socket_state}
    rescue
      unknown_error ->
        Logger.error("Unexpected error happened: #{inspect(unknown_error)}")
        {:noreply, assign(socket, notifications: %{error: "Something went wrong"})}
    catch
      state -> {:noreply, state}
    end
  end

  def clear_notifications(socket), do: assign(socket, notifications: %{})

  defp parse_params(
         socket,
         %{
           "balance" => balance,
           "startDate" => start_date,
           "allocation" => allocation,
           "rebalancing" => rebalancing
         } = input_params
       ) do
    try do
      parsed_params = %{
        balance: String.to_integer(balance) * 100,
        date_from: TimexHelper.to_date(start_date, "{YYYY}-{0M}-{D}"),
        allocation: parse_allocation(allocation),
        options: [rebalancing: rebalancing]
      }

      assign(socket, input_params: input_params, parsed_params: parsed_params)
    rescue
      _ -> throw(assign(socket, notifications: %{warning: "Invalid input"}))
    end
  end

  defp parse_params(socket, _), do: throw(assign(socket, error: "Invalid input"))

  defp parse_allocation(allocation) do
    allocation
    |> Enum.reject(fn
      {_, %{"ticker" => ticker, "value" => value}} -> ticker == "" || value == ""
    end)
    |> Enum.into(%{}, fn {_, %{"ticker" => ticker, "value" => value}} ->
      {ticker, String.to_integer(value)}
    end)
  end

  defp validate_params(%Socket{assigns: %{parsed_params: %{allocation: allocation}}} = socket) do
    allocation
    |> Map.values()
    |> Enum.sum()
    |> case do
      100 -> assign(socket, validation_errors: %{})
      _ -> throw(assign(socket, validation_errors: %{allocation: "Total must be 100%"}))
    end
  end

  defp build_performance(%Socket{assigns: %{parsed_params: params}} = socket) do
    case Performance.build(params.balance, params.allocation, params.date_from, params.options) do
      {:ok, performance} -> assign(socket, performance: performance)
      {:error, msg} -> assign(socket, notifications: %{warning: msg})
    end
  end
end
