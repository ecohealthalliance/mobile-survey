{ moment } = require 'meteor/momentjs:moment'
{ mostCommonItem } = require 'meteor/gq:helpers'

Template.datetime_results.onCreated ->
  dateTimeStamps = []
  momentDates = []

  @data.answers.find().forEach (answer) ->
    date = answer.content
    dateTimeStamps.push new Date(date).valueOf()
    momentDates.push moment date

  @summaryDetails = new Meteor.Collection null

  if dateTimeStamps.length > 1
    total = 0
    for dateTimeStamp in dateTimeStamps
      total += dateTimeStamp
    average = new Date Math.round(total / dateTimeStamps.length)
    average = moment(average)

    @summaryDetails.insert
      detailName: 'Average'
      date: average.format 'MMMM D, YYYY'
      time: average.format 'h:mm:ss a'

  latest = moment.min momentDates
  @summaryDetails.insert
    detailName: 'Latest'
    date: latest.format 'MMMM D, YYYY'
    time: latest.format 'h:mm:ss a'

  earliest = moment.max momentDates
  @summaryDetails.insert
    detailName: 'Earliest'
    date: earliest.format 'MMMM D, YYYY'
    time: earliest.format 'h:mm:ss a'

  if @data.question.type is 'date'
    _dates = dateTimeStamps.sort()

    { mostCommon, count } = mostCommonItem _dates

    if mostCommon and count > 1
      @summaryDetails.insert
        detailName: 'Most Common'
        date: moment(mostCommon).format 'MMMM D, YYYY'
        count: count

Template.datetime_results.helpers
  summaryDetails: ->
    Template.instance().summaryDetails.find()

  datetime: ->
    Template.instance().data.type is 'datetime'

  averageDate: ->
    Template.instance().summaryDetails.findOne detailName: 'Average'

  earliestDate: ->
    Template.instance().summaryDetails.findOne detailName: 'Earliest'

  latestDate: ->
    Template.instance().summaryDetails.findOne detailName: 'Latest'

  mostCommonDate: ->
    Template.instance().summaryDetails.findOne detailName: 'Most Common'
