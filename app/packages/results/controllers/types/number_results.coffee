{ showGaugeChart } = require '../../imports/highcharts_helpers'

Template.number_results.onRendered ->
  showGaugeChart @, 'number'
