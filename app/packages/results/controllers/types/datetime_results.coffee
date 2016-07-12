{ moment } = require 'meteor/momentjs:moment'

Template.datetime_results.onCreated ->
  dates = _.pluck @data.answers, 'iso'
  @dates = _.map dates, (date) ->
    moment date

Template.datetime_results.helpers
  average: ->
    dates = Template.instance().dates
    total = 0
    for date in dates
      total += new Date(date).valueOf()
    average = new Date Math.round(total / dates.length)
    moment(average).format 'MMMM Do YYYY, h:mm:ss a'

  latest: ->
    moment.min(Template.instance().dates).format 'MMMM Do YYYY, h:mm:ss a'

  earliest: ->
    moment.max(Template.instance().dates).format 'MMMM Do YYYY, h:mm:ss a'
