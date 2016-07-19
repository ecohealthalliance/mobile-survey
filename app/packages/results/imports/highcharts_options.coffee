gaugeOptions =
  chart:
    type: 'solidgauge'
    style: {}
  title: null
  colors: ['rgba(162, 214, 134, 1)']
  pane:
    center: ['50%', '50%']
    size: '90%'
    startAngle: -90
    endAngle: 90
    background:
      backgroundColor: 'RGBA(231, 231, 231, 1.00)'
      innerRadius: '60%'
      outerRadius: '100%'
      shape: 'arc'
      stops: ['red']
      borderWidth: 0
  tooltip: enabled: false
  yAxis:
    lineWidth: 0
    title: y: -70
    labels: y: 16
    lineColor: 'red'
    gridLineColor: 'blue'
  plotOptions: solidgauge: dataLabels:
    y: 5
    borderWidth: 0
    useHTML: true
  yAxis:
    labels:
      align: 'center'
  credits: enabled: false

label = (value, label) ->
  """
    <div class='gauge-title'>
       <span class='statistic major'>#{value}</span>
       <div class='separator full-width'></div>
       <h5>#{label}</h5>
     </div>
  """

buildGaugeChartOptions = (props, answers) ->
  total = 0
  total = _.reduce answers, (answer, nextAnswer) ->
    answer + nextAnswer
  average = Math.round(total/answers.length)

  lowest = _.min answers
  highest = _.max answers

  yAxis = gaugeOptions.yAxis
  yAxis = _.extend yAxis, {min: props.min, max: props.max}

  averageChartOptions = Highcharts.merge gaugeOptions,
    series: [{
      name: 'average'
      data: [ average ]
      dataLabels:
        format: label(average, 'Average')
        style: {top: '-50px'}
    }]

  lowestChartOptions = Highcharts.merge gaugeOptions,
    series: [{
      name: 'lowest'
      data: [ lowest ]
      dataLabels:
        format: label(lowest, 'Lowest')
    }]

  highestChartOptions = Highcharts.merge gaugeOptions,
    series: [{
      name: 'highest'
      data: [ highest ]
      dataLabels:
        format: label(highest, 'Highest')
    }]

  averageChartOptions: averageChartOptions
  lowestChartOptions: lowestChartOptions
  highestChartOptions: highestChartOptions

module.exports =
  buildGaugeChartOptions: buildGaugeChartOptions
