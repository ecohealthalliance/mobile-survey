randomcolor = require 'randomcolor'
{ pluckAnswers } = require '../../imports/results_helpers'

Template.multiple_results.onCreated ->
  @stats = new Meteor.Collection null

Template.multiple_results.onRendered ->
  choices = @data.question.properties.choices
  answers = pluckAnswers @data.answers
  @chartData = []

  _.each choices, (choice) =>
    occurences = _.filter answers, (answer) -> answer is choice
    count = occurences.length
    @stats.insert
      choice: choice
      count: count
      percentage: (count / answers.length) * 100
    @chartData.push [choice, count]

  chartColors = randomcolor
    count: choices.length

  @$('.multiple-chart').highcharts
    chart:
      type: 'pie'
      options3d:
        enabled: true
        alpha: 45
        beta: 0
    credits: enabled: false
    colors: chartColors
    title: null
    plotOptions:
      pie:
        allowPointSelect: true
        cursor: 'pointer'
        depth: 35
        showInLegend: true
        dataLabels:
          enabled: false
          format: '{point.name}'
    tooltip:
      pointFormat: '<b>{point.percentage:.1f}%</b> ({point.y})'
    series: [{
      type: 'pie'
      name: null
      data: @chartData
    }]

Template.multiple_results.helpers
  detailedResults: ->
    Template.instance().stats.find()
