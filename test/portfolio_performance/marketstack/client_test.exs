defmodule PortfolioPerformance.Marketstack.ClientTest do
  use ExUnit.Case
  import PortfolioPerformance.Marketstack.TestHelper
  alias PortfolioPerformance.Marketstack.Client

  @access_key Application.fetch_env!(:portfolio_performance, :marketstack_access_key)
  @test_base_url Application.fetch_env!(:portfolio_performance, :marketstack_url)

  @symbol "TWTR"
  @date_from "2019-12-30"
  @options [date_from: @date_from]

  describe "full_history" do
    setup do
      query = [symbols: @symbol, limit: 1000] ++ @options ++ [access_key: @access_key]
      url = @test_base_url <> "eod"

      Tesla.Mock.mock(fn
        %{url: ^url, method: :get, query: ^query} ->
          %Tesla.Env{status: 200, body: %{"data" => ["some data"]}}

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
    setup [:marketstack_error_mock]

    test "process", %{mock: body} do
      assert {:error, error_msg} = Client.full_history(@symbol, @options)
      assert error_msg == body["error"]["message"]
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
