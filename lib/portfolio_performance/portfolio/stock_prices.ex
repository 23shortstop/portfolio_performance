defmodule PortfolioPerformance.Portfolio.StockPrices do
  alias PortfolioPerformance.{Marketstack, TimexHelper}

  @price_key "close"

  @type stock_prices :: %{String.t() => integer()}
  @type multi_history :: [{Date.t(), stock_prices()}]
  @type result :: {:ok, multi_history()} | {:error, String.t()}

  @spec monthly_multi_full_history(list(String.t()), Date.t()) :: result()
  def monthly_multi_full_history(tickers, date_from) do
    try do
      prices =
        tickers
        |> Enum.flat_map(&full_history(&1, date_from: Date.to_string(date_from)))
        |> group_by_date
        |> filter_monthly
        |> Enum.filter(fn {_, stocks} -> Enum.count(stocks) == length(tickers) end)
        |> Enum.sort_by(fn {date, _prices} -> Date.to_erl(date) end)

      {:ok, prices}
    catch
      {:error, message} -> {:error, "Unable to receive stock prices: #{message}"}
    end
  end

  defp full_history(ticker, options) do
    with {:ok, history} <- Marketstack.Client.full_history(ticker, options) do
      history
      |> Enum.map(fn %{"date" => date, @price_key => price} ->
        {TimexHelper.to_date(date), %{ticker => to_cents(price)}}
      end)
      |> Enum.into(%{})
    else
      {:error, message} -> throw({:error, message})
    end
  end

  defp to_cents(float_dollar_price) do
    float_dollar_price
    |> (&(&1 * 100)).()
    |> trunc
  end

  defp filter_monthly(history) do
    {last_date, last_value} = Enum.max_by(history, fn {date, _} -> Date.to_erl(date) end)

    history
    |> Enum.group_by(fn {date, _} -> {date.year, date.month} end)
    |> Enum.map(fn {_, data} ->
      data |> Enum.min_by(fn {date, _} -> Date.to_erl(date) end)
    end)
    |> Enum.into(%{})
    |> Map.put(last_date, last_value)
  end

  defp group_by_date(stocks_price) do
    stocks_price
    |> Enum.group_by(fn {date, _} -> date end, fn {_, prices} -> prices end)
    |> Enum.flat_map(fn {date, prices} -> %{date => Enum.reduce(prices, &Map.merge/2)} end)
  end
end
