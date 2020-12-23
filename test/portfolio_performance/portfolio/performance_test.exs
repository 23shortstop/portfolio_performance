defmodule PortfolioPerformance.PerformanceTest do
  use ExUnit.Case
  alias PortfolioPerformance.Performance
  import PortfolioPerformance.Marketstack.TestHelper

  @balance 10_000_001
  @date_from Timex.today() |> Timex.shift(years: -3)

  describe "success" do
    setup [:world_trade_success_mock]

    test "build", %{mock: body} do
      ticker = body["name"]
      allocation = %{ticker => 100}
      assert {:ok, performance} = Performance.build(@balance, allocation, @date_from)
    end
  end

  describe "error" do
    setup [:world_trade_error_mock]

    test "build", %{mock: _body} do
      allocation = %{"TWTR" => 70, "SNAP" => 30}
      assert {:error, _msg} = Performance.build(@balance, allocation, @date_from)
    end
  end
end
