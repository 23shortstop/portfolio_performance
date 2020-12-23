defmodule PortfolioPerformance.TimexHelper do
  @date_format "{ISO:Extended}"

  def to_date(string_date, format \\ @date_format) do
    string_date
    |> Timex.parse!(format)
    |> Timex.to_date()
  end
end
