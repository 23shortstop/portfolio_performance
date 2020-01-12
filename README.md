# PortfolioPerformance

## Description

- A web application where you can enter the state of your assets portfolio at some day in the past and see how much money would be worth today.

#### Example: 
- Start Date: 2013-03-20
- Initial Balance: $32500
- Portfolio Allocation:
  - AAPL: 20%
  - GOOG: 50%
  - VTI: 30%

## Live staging is available here:
https://portfolio-performance.herokuapp.com

## To start the app locally:

The [World Trading Data API](https://www.worldtradingdata.com/) is using to obtain historical trading data for stocks.
You need to [register](https://www.worldtradingdata.com/register) and get your own API token.

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install && cd ..`
  * Start Phoenix endpoint with `WORLD_TRADING_TOKEN=your_api_token mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
