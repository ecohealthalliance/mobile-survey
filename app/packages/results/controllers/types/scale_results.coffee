{ showGaugeChart } = require '../../imports/highcharts_helpers'

Template.scale_results.onRendered ->
  showGaugeChart @, 'scale'
