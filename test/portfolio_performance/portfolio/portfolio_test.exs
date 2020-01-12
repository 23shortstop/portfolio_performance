defmodule PortfolioPerformance.PortfolioTest do
  use ExUnit.Case
  alias PortfolioPerformance.Portfolio

  @balance 10_000_001
  @tickers ["SNAP", "TWTR", "QWER", "ASD", "ZXC"]
  @stock_prices [1001, 5001, 10001, 25001, 50001]
  @percentage [40, 25, 20, 10, 5]
  @percentage_delta 1

  describe "allocate" do
    test "according to percentage allocation" do
      allocation = @tickers |> Enum.zip(@percentage) |> Enum.into(%{})
      prices = @tickers |> Enum.zip(@stock_prices) |> Enum.into(%{})

      portfolio = Portfolio.allocate(@balance, allocation, prices)

      # Check that actual allocation approximately equals to expected.
      portfolio.assets
      |> Enum.each(fn {ticker, %{price: price, amount: amount}} ->
        actual_percentage = amount * price / @balance * 100
        expected_percentage = Map.get(allocation, ticker)
        assert_in_delta(actual_percentage, expected_percentage, @percentage_delta)
      end)

      # Check balance allocation optimality
      min_stock_price = @stock_prices |> Enum.min()
      assert portfolio.unused_balance < min_stock_price

      # Check that if we will calculate balance based on the allocation results
      # we will receive initial balance value
      %Portfolio{balance: calculated_balance} = Portfolio.calculate_balance(portfolio, prices)
      assert @balance == calculated_balance
    end
  end
end
