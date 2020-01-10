defmodule PortfolioPerformance.TimexHelper do
  @date_format "{YYYY}-{0M}-{0D}"

  def to_date(string_date, format \\ @date_format) do
    string_date
    |> Timex.parse!(format)
    |> NaiveDateTime.to_date()
  end
end
