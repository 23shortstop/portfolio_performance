defmodule PortfolioPerformance.WorldTrading.ClientTest do
  use ExUnit.Case
  import PortfolioPerformance.WorldTrading.TestHelper
  alias PortfolioPerformance.WorldTrading.Client

  @test_token Application.fetch_env!(:portfolio_performance, :world_trading_token)
  @test_base_url Application.fetch_env!(:portfolio_performance, :world_trading_url)

  @symbol "TWTR"
  @date_from "2019-12-30"
  @options [date_from: @date_from]

  describe "full_history" do
    setup do
      query = [{:symbol, @symbol}] ++ @options ++ [{:api_token, @test_token}]
      url = @test_base_url <> "/history"

      Tesla.Mock.mock(fn
        %{url: ^url, method: :get, query: ^query} ->
          %Tesla.Env{body: %{"history" => "some data", "name" => "QQQ"}}

        %{url: ^url, method: :get, query: wrong_query} ->
          raise "Query is incorrect: #{inspect(wrong_query)}"

        %{url: wrong_url, method: :get, query: ^query} ->
          raise "URL is incorrect: #{inspect(wrong_url)}"

        incorrect_env ->
          raise "Request is incorrect: #{inspect(incorrect_env)}"
      end)

      :ok
    end

    test "sends correct request" do
      assert {:ok, _} = Client.full_history(@symbol, @options)
    end
  end

  describe "error response" do
    setup [:world_trade_error_mock]

    test "process", %{mock: body} do
      assert {:error, error_msg} = Client.full_history(@symbol, @options)
      assert error_msg == (body["message"] || body["Message"])
    end
  end

  describe "no response" do
    setup do
      Tesla.Mock.mock(fn _ -> {:error, :econnrefused} end)
      :ok
    end

    test "process" do
      assert {:error, _error_msg} = Client.full_history(@symbol, @options)
    end
  end
end
