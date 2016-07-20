randomcolor = require 'randomcolor'
{ pluckAnswers } = require '../../imports/results_helpers'

Template.multiple_results.onCreated ->
  @stats = new Meteor.Collection null

Template.multiple_results.onRendered ->
  question  = @data.question
  choices   = question.properties.choices
  answers = pluckAnswers @data.answers
  chartData = []

  if question.type is 'checkboxes'
    answerCounts = _.countBy _.flatten(answers)
    for choice, count of answerCounts
      chartData.push [choice, count]
  else
    _.each choices, (choice) =>
      occurences = _.filter answers, (answer) -> answer is choice
      chartData.push [choice,  occurences.length]

  _.each chartData, (dataPoint) =>
    choice = dataPoint[0]
    count = dataPoint[1]
    @stats.insert
      choice: choice
      count: count
      percentage: (count / answers.length) * 100

  chartColors = randomcolor
    count: choices.length

  @$('.multiple-chart').highcharts
    chart:
      type: 'pie'
    credits: enabled: false
    colors: chartColors
    title: null
    plotOptions:
      pie:
        allowPointSelect: true
        cursor: 'pointer'
        showInLegend: true
        dataLabels:
          enabled: false
          format: '{point.name}'
    tooltip:
      pointFormat: '<b>{point.percentage:.1f}%</b> ({point.y})'
    series: [{
      type: 'pie'
      name: null
      data: chartData
    }]

Template.multiple_results.helpers
  detailedResults: ->
    Template.instance().stats.find {}, sort: count: -1
