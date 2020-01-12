import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

import {BuildChartHook} from "./portfolio_chart"

let Hooks = {}

Hooks.BuildChart = BuildChartHook

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})

liveSocket.connect()
