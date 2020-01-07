defmodule PortfolioPerformance.WorldTrading.Client do
  use Tesla

  @type history_options :: [
          date_from: String.t(),
          date_to: String.t(),
          sort: :desc | :asc,
          output: :csv | :json,
          formatted: true | false
        ]
  @type data :: %{required(String.t()) => any}
  @type result :: {:ok, data} | {:error, String.t()}

  @token Application.fetch_env!(:portfolio_performance, :world_trading_token)
  @base_url Application.fetch_env!(:portfolio_performance, :world_trading_url)

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.Query, api_token: @token
  plug Tesla.Middleware.DecodeJson

  @spec full_history(String.t(), history_options) :: result
  def full_history(symbol, options \\ []) do
    get("history", query: [{:symbol, symbol} | options])
    |> process_response
  end

  defp process_response({:ok, %{body: %{"history" => history}}}) do
    {:ok, history}
  end

  defp process_response({:ok, %{body: %{"Message" => error_message}}}) do
    {:error, error_message}
  end

  defp process_response({:ok, %{body: %{"message" => error_message}}}) do
    {:error, error_message}
  end

  defp process_response(_error) do
    {:error, "Unable to receive data from World Trading Data API"}
  end
end
