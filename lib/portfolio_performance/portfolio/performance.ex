defmodule PortfolioPerformance.Performance do
  alias PortfolioPerformance.{Portfolio.StockPrices, Portfolio}

  @type options :: [rebalancing: String.t()]
  @type performance :: %{Date.t() => Portfolio.t()}
  @type result :: {:ok, performance()} | {:error, String.t()}

  @spec build(integer(), Portfolio.allocation(), Date.t(), options()) :: result()
  def build(balance, allocation, date_from, options \\ []) do
    tickers = Map.keys(allocation)

    with {:ok, stocks_history} <- StockPrices.monthly_multi_full_history(tickers, date_from) do
      {:ok, build_with_price_history(balance, allocation, stocks_history, options)}
    end
  end

  defp build_with_price_history(balance, allocation, price_history, options) do
    [{initial_date, initial_prices} | stocks_history] = price_history

    initial_state = Portfolio.allocate(balance, allocation, initial_prices)

    stocks_history
    |> Enum.scan({initial_date, initial_state}, fn
      {current_date, current_prices}, {previous_date, previous_state} ->
        if rebalance?(current_date, previous_date, options) do
          current_balance = Portfolio.calculate_balance(previous_state, current_prices).balance

          {current_date, Portfolio.allocate(current_balance, allocation, current_prices)}
        else
          {current_date, Portfolio.calculate_balance(previous_state, current_prices)}
        end
    end)
    |> Enum.into(%{})
    |> Map.put(initial_date, initial_state)
  end

  defp rebalance?(current_date, previous_date, options) do
    case Keyword.get(options, :rebalancing) do
      "monthly" -> current_date.month != previous_date.month
      "yearly" -> current_date.year != previous_date.year
      _ -> false
    end
  end
end
