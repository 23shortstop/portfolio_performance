defmodule PortfolioPerformance.Portfolio do
  alias PortfolioPerformance.Portfolio.StockPrices

  @type t :: %__MODULE__{
          balance: integer,
          unused_balance: integer,
          assets: %{String.t() => %{amount: integer, price: integer}}
        }

  @derive Jason.Encoder
  defstruct [:balance, :unused_balance, :assets]

  @type allocation :: %{String.t() => integer()}
  @type stock_amounts :: %{String.t() => integer()}

  @spec allocate(integer(), allocation, StockPrices.stock_prices()) :: t()
  def allocate(balance, allocation, stock_prices) do
    last_index = Enum.count(stock_prices) - 1

    {stock_amounts, unused_balance} =
      stock_prices
      |> Enum.to_list()
      |> Enum.sort(fn {_, price1}, {_, price2} -> price1 > price2 end)
      |> Enum.with_index()
      |> Enum.map_reduce(balance, fn {{ticker, price}, index}, unused_balance ->
        max_stock_balance =
          if index == last_index do
            unused_balance
          else
            (balance * Map.get(allocation, ticker)) |> div(100)
          end

        stock_amount = div(max_stock_balance, price)
        actual_stock_balance = stock_amount * price
        {{ticker, %{amount: stock_amount, price: price}}, unused_balance - actual_stock_balance}
      end)

    %__MODULE__{
      balance: balance,
      unused_balance: unused_balance,
      assets: Enum.into(stock_amounts, %{})
    }
  end

  @spec calculate_balance(t(), StockPrices.stock_prices()) :: t()
  def calculate_balance(portfolio, new_prices) do
    {new_assets, balance} =
      portfolio.assets
      |> Enum.map_reduce(portfolio.unused_balance, fn {ticker, %{amount: amount}}, acc ->
        new_price = Map.get(new_prices, ticker)
        new_asset = {ticker, %{amount: amount, price: new_price}}
        new_balance = new_price * amount + acc
        {new_asset, new_balance}
      end)

    %__MODULE__{
      balance: balance,
      unused_balance: portfolio.unused_balance,
      assets: Enum.into(new_assets, %{})
    }
  end
end
