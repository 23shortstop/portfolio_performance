defmodule PortfolioPerformance.WorldTrading.TestHelper do
  def world_trade_success_mock(_) do
    mock_body =
      File.read!("test/support/world_trading/fixtures/full_history/success.json")
      |> Jason.decode!()

    Tesla.Mock.mock(fn _ -> {200, %{}, mock_body} end)
    {:ok, mock: mock_body}
  end

  def world_trade_error_mock(_) do
    mock_body =
      File.read!("test/support/world_trading/fixtures/full_history/error.json")
      |> Jason.decode!()

    Tesla.Mock.mock(fn _ -> {400, %{}, mock_body} end)
    {:ok, mock: mock_body}
  end
end
