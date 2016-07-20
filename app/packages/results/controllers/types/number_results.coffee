highchartOptions = require '../../imports/highcharts_options'

Template.number_results.onRendered ->
  props = @data.question.properties
  answers = _.pluck @data.answers.find().fetch(), 'content'

  {averageChartOptions, lowestChartOptions, highestChartOptions} =
    highchartOptions.buildGaugeChartOptions props, answers

  @$('.number-average').highcharts averageChartOptions
  @$('.number-min').highcharts lowestChartOptions
  @$('.number-max').highcharts highestChartOptions
