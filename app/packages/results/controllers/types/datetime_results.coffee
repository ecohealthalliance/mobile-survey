{ moment } = require 'meteor/momentjs:moment'

Template.datetime_results.onCreated ->
  dates = _.pluck @data.answers, 'iso'
  @dates = _.map dates, (date) ->
    moment date

  @summaryDetails = new Meteor.Collection null

  total = 0
  for date in dates
    total += new Date(date).valueOf()
  average = new Date Math.round(total / dates.length)
  average = moment(average)

  @summaryDetails.insert
    detailName: 'Average'
    date: average.format 'MMMM Do YYYY'
    time: average.format 'h:mm:ss a'

  latest = moment.min @dates
  @summaryDetails.insert
    detailName: 'Latest'
    date: latest.format 'MMMM Do YYYY'
    time: latest.format 'h:mm:ss a'

  earliest = moment.max @dates
  @summaryDetails.insert
    detailName: 'Earliest'
    date: earliest.format 'MMMM Do YYYY'
    time: earliest.format 'h:mm:ss a'

Template.datetime_results.helpers
  summaryDetails: ->
    Template.instance().summaryDetails.find()
