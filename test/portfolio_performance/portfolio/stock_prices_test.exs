defmodule PortfolioPerformance.Portfolio.StockPricesTest do
  use ExUnit.Case
  alias PortfolioPerformance.Portfolio.StockPrices
  import PortfolioPerformance.Marketstack.TestHelper

  @date_from Timex.to_datetime({2019, 9, 15})
  @start_of_next_month @date_from |> Timex.end_of_month() |> Timex.shift(days: 1)
  @midle_of_next_month @start_of_next_month |> Timex.shift(days: 15)
  @date_to @start_of_next_month |> Timex.end_of_month()

  @all_dates [@date_from, @start_of_next_month, @midle_of_next_month, @date_to]

  @data_sample %{"close" => 309.76, "symbol" => "QQQ"}

  @history_sample @all_dates
                  |> Enum.map(&Map.put(@data_sample, "date", DateTime.to_string(&1)))

  @tickers ["TWTR", "SNAP"]

  describe "success monthly_multi_full_history" do
    setup do
      Tesla.Mock.mock(fn %{query: [{:symbols, _symbol} | _]} ->
        %Tesla.Env{status: 200, body: %{"data" => @history_sample}}
      end)

      :ok
    end

    test "filters results monthly" do
      {:ok, multi_history} = StockPrices.monthly_multi_full_history(@tickers, @date_from)

      result_dates = multi_history |> Keyword.keys()
      assert result_dates |> Enum.member?(DateTime.to_date(@date_from))
      assert result_dates |> Enum.member?(DateTime.to_date(@start_of_next_month))
      assert result_dates |> Enum.member?(DateTime.to_date(@date_to))
      refute result_dates |> Enum.member?(DateTime.to_date(@midle_of_next_month))
    end

    test "merges histories for many stocks" do
      {:ok, multi_history} = StockPrices.monthly_multi_full_history(@tickers, @date_from)

      multi_history
      |> Enum.each(fn {_date, data} ->
        assert @tickers |> Enum.all?(fn ticker -> data |> Map.keys() |> Enum.member?(ticker) end)
      end)
    end

    test "parses string price in dollars to integer in cents" do
      {:ok, multi_history} = StockPrices.monthly_multi_full_history(@tickers, @date_from)

      multi_history
      |> Enum.each(fn {_date, data} ->
        data
        |> Enum.each(fn {_, price} ->
          assert price === (@data_sample["close"] * 100) |> trunc
        end)
      end)
    end

    test "sorts history by dates" do
      {:ok, multi_history} = StockPrices.monthly_multi_full_history(@tickers, @date_from)

      keys = multi_history |> Keyword.keys()
      assert keys == keys |> Enum.sort_by(&Date.to_erl/1)
    end
  end

  describe "error responce from Marketstack" do
    setup [:marketstack_error_mock]

    test "returns error tuple" do
      {:error, _} = StockPrices.monthly_multi_full_history(@tickers, @date_from)
    end
  end
end
