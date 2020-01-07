defmodule PortfolioPerformance.Portfolio.StockPricesTest do
  use ExUnit.Case
  alias PortfolioPerformance.Portfolio.StockPrices
  import PortfolioPerformance.WorldTrading.TestHelper

  @date_from Timex.to_date({2019, 9, 15})
  @start_of_next_month @date_from |> Timex.end_of_month() |> Timex.shift(days: 1)
  @midle_of_next_month @start_of_next_month |> Timex.shift(days: 15)
  @date_to @start_of_next_month |> Timex.end_of_month()

  @all_dates [@date_from, @start_of_next_month, @midle_of_next_month, @date_to]

  @data_sample %{
    "open" => "16.62",
    "close" => "16.78",
    "high" => "16.95",
    "low" => "16.46",
    "volume" => "26030811"
  }

  @history_sample @all_dates
                  |> Enum.map(fn date -> {date |> Date.to_string(), @data_sample} end)
                  |> Enum.into(%{})

  @tickers ["TWTR", "SNAP"]

  describe "success monthly_multi_full_history" do
    setup do
      Tesla.Mock.mock(fn
        %{query: [{:symbol, symbol} | _]} ->
          %Tesla.Env{body: %{"name" => symbol, "history" => @history_sample}}
      end)

      :ok
    end

    test "filters results monthly" do
      {:ok, multi_history} = StockPrices.monthly_multi_full_history(@tickers, @date_from)

      result_dates = multi_history |> Keyword.keys()
      assert result_dates |> Enum.member?(@date_from)
      assert result_dates |> Enum.member?(@start_of_next_month)
      assert result_dates |> Enum.member?(@date_to)
      refute result_dates |> Enum.member?(@midle_of_next_month)
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
          assert price === String.to_float(@data_sample["close"]) * 100 |> trunc
        end)
      end)
    end
  end

  describe "error responce from World Trading" do
    setup [:world_trade_error_mock]

    test "returns error tuple" do
      {:error, _} = StockPrices.monthly_multi_full_history(@tickers, @date_from)
    end
  end
end
