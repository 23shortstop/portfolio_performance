defmodule PortfolioPerformance.Portfolio.StockPrices do
  alias PortfolioPerformance.WorldTrading
  require Logger

  @date_format "{YYYY}-{0M}-{0D}"
  @price_key "close"

  @type stock_prices :: %{String.t() => integer()}
  @type multi_history :: [{Date.t(), stock_prices()}]
  @type result :: {:ok, multi_history()} | {:error, String.t()}

  @spec monthly_multi_full_history(list(String.t()), Date.t()) :: result()
  def monthly_multi_full_history(tickers, date_from) do
    try do
      prices =
        tickers
        |> Enum.map(&full_history(&1, date_from: Date.to_string(date_from)))
        |> Enum.map(&filter_monthly/1)
        |> Enum.zip()
        |> Enum.flat_map(&group_by_date/1)
        |> Enum.sort_by(fn {date, _prices} -> Date.to_erl(date) end)

      {:ok, prices}
    catch
      {:error, msg} ->
        Logger.warn("Full history request failed with error: #{msg}")
        {:error, "Unable to receive stock prices"}
    end
  end

  defp full_history(ticker, options) do
    with {:ok, %{"history" => history, "name" => name}} <-
           WorldTrading.Client.full_history(ticker, options) do
      history
      |> Enum.map(fn {date, %{@price_key => price}} ->
        {to_date(date), %{name => to_cents(price)}}
      end)
      |> Enum.into(%{})
    else
      api_error -> throw(api_error)
    end
  end

  defp to_date(string_date) do
    string_date
    |> Timex.parse!(@date_format)
    |> NaiveDateTime.to_date()
  end

  defp to_cents(string_dollar_price) do
    string_dollar_price
    |> String.to_float()
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
    |> Tuple.to_list()
    |> Enum.group_by(fn {date, _} -> date end, fn {_, prices} -> prices end)
    |> Enum.flat_map(fn {date, prices} -> %{date => Enum.reduce(prices, &Map.merge/2)} end)
  end
end