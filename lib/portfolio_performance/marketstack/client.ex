defmodule PortfolioPerformance.Marketstack.Client do
  use Tesla
  require Logger

  @type history_options :: [
          date_from: String.t(),
          date_to: String.t(),
          sort: :desc | :asc,
          output: :csv | :json,
          formatted: true | false
        ]
  @type data :: %{required(String.t()) => any}
  @type result :: {:ok, data} | {:error, String.t()}

  @access_key Application.fetch_env!(:portfolio_performance, :marketstack_access_key)
  @base_url Application.fetch_env!(:portfolio_performance, :marketstack_url)

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.Query, access_key: @access_key
  plug Tesla.Middleware.DecodeJson

  @max_limit 1000
  @spec full_history(String.t(), history_options) :: result
  def full_history(symbol, options) do
    get("eod", query: [limit: @max_limit, symbols: symbol] ++ options)
    |> process_response
  end

  defp process_response({:ok, %{status: 200, body: %{"data" => data}}}) do
    {:ok, data}
  end

  defp process_response({:ok, %{body: %{"error" => %{"message" => error_message}}}}) do
    {:error, error_message}
  end

  defp process_response(unexpected) do
    Logger.error("An unexpected response received from Marketstack API: #{inspect(unexpected)}")
    {:error, "Unable to receive data from Marketstack API"}
  end
end
