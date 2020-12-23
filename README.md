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

The [Marketstack API](https://marketstack.com/) is using to obtain historical trading data for stocks.
You need to [register](https://marketstack.com/product) and get your own API token.

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install --prefix assets`
  * Start Phoenix endpoint with `MARKETSTACK_ACCESS_KEY=your_access_key mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
