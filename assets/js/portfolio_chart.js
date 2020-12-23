import 'chartjs-plugin-colorschemes';

export let BuildChartHook = {
  buildChart() {
    let portfolio = JSON.parse(this.el.dataset.chart);
    let Chart = require('chart.js');
    let ctx = this.el;
    return new Chart(ctx, {
      type: 'line',
      data: chart_data(portfolio),
      options: {
        title: {
          display: true,
          text: "Portfolio Performance Chart"
        },
        scales: {
            yAxes: [{
              scaleLabel: {
                display: true,
                labelString: "Balance, $"
              }
            }],
            xAxes: [{
                type: 'time',
                time: {
                    unit: 'month'
                }
            }]
        },
        plugins: {
            colorschemes: {
                scheme: 'brewer.Paired12'
            }
        }
      }
    });
  },

  mounted() {
    this.chart = this.buildChart();
  },

  updated() {
    if (typeof this.chart !== 'undefined') {
        this.chart.destroy();
        this.chart = this.buildChart();
    } else {
      this.chart = this.buildChart();
    }
  }
}

function chart_data(json) {
  let array_data = Object.keys(json).map(key => [new Date(key), json[key]]);

  if (array_data.length == 0) return {};

  array_data.sort((a, b) => a[0] - b[0]);

  let stocks = Object.keys(array_data[0][1].assets);

  let total_data = []
  let labels = []
  array_data.forEach(function(data) {
    labels.push(data[0])
    total_data.push(data[1].balance / 100)
  });

  let stocks_dataset = stocks.map(function(ticker) {
    return {
      data: array_data.map(v => (v[1].assets[ticker].price * v[1].assets[ticker].amount) / 100),
      label: ticker,
      fill: false
    }
  });

  stocks_dataset.push({
    data: total_data,
    label: "Total balance",
    fill: false
  })

  return {
    labels: labels,
    datasets: stocks_dataset
  }
};
